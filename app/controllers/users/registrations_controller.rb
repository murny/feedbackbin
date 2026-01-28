# frozen_string_literal: true

module Users
  # Tenanted registration controller for creating a new User within a specific account.
  # Shows account-branded registration page.
  # For creating a new Account (tenant), see SignupsController.
  class RegistrationsController < ApplicationController
    include AuthLayout

    allow_unauthenticated_access
    skip_before_action :ensure_account_user
    before_action :redirect_authenticated_user, only: %i[new create]

    rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to users_sign_up_path, alert: t("users.registrations.create.rate_limited") }

    def new
      @user = User.new
      @identity = Identity.new
      @invitation = Invitation.find_by(token: params[:invitation_token]) if params[:invitation_token]

      if @invitation
        # Pre-fill form with invitation data
        @identity.email_address = @invitation.email
        @user.name = @invitation.name
      end
    end

    def create
      @invitation = Invitation.find_by(token: params[:invitation_token]) if params[:invitation_token]
      @new_identity = false

      ActiveRecord::Base.transaction do
        @identity = find_or_create_identity
        @user = create_user_for_account

        handle_invitation if @invitation

        # Only create session if invitation (already verified) or existing verified identity
        if @invitation || !@new_identity || @identity.email_verified_at.present?
          start_new_session_for(@identity)
        end
      end

      if @new_identity && @invitation.nil?
        IdentityMailer.email_verification(@identity).deliver_later
        redirect_to pending_users_email_verification_path, notice: t(".verification_email_sent")
      else
        redirect_to root_path, notice: t(".signed_up_successfully")
      end
    rescue ActiveRecord::RecordInvalid
      @identity ||= Identity.new(identity_params)
      @user ||= User.new(user_params)
      render :new, status: :unprocessable_entity
    end

    private

      def find_or_create_identity
        existing_identity = Identity.find_by(email_address: identity_params[:email_address])

        if existing_identity
          @identity = existing_identity.tap { |i| i.errors.add(:email_address, :already_registered) }
          raise ActiveRecord::RecordInvalid.new(@identity)
        else
          @new_identity = true
          @identity = Identity.create!(identity_params)
        end
      end

      def create_user_for_account
        # Check if user already exists for this account (active or deactivated)
        existing_user = @identity.users.find_by(account: Current.account)
        if existing_user
          if existing_user.active?
            @user = User.new.tap { |u| u.errors.add(:base, :already_registered) }
            raise ActiveRecord::RecordInvalid.new(@user)
          else
            @user = User.new.tap { |u| u.errors.add(:base, :account_deactivated) }
            raise ActiveRecord::RecordInvalid.new(@user)
          end
        end

        @user = User.create!(
          user_params.merge(
            identity: @identity,
            account: Current.account,
            role: :member
          )
        )
      end

      def handle_invitation
        if @invitation.account == Current.account
          @invitation.accept!(@user)
        end
        @identity.update!(email_verified_at: Time.current) if @invitation
      end

      def redirect_authenticated_user
        # If already authenticated, check if they have a user for this account
        return unless authenticated?

        existing_user = Current.identity.users.find_by(account: Current.account)
        if existing_user
          if existing_user.active?
            redirect_to root_path
          else
            redirect_to root_path, alert: t("users.registrations.account_deactivated")
          end
        else
          # Authenticated but no user for this account - auto-create their membership
          auto_join_account
        end
      end

      def auto_join_account
        user = Current.identity.users.create!(
          account: Current.account,
          name: Current.identity.email_address.split("@").first.titleize,
          role: :member
        )
        redirect_to root_path, notice: t("users.registrations.joined_account", account_name: Current.account.name)
      end

      def user_params
        params.expect(user: [ :name ])
      end

      def identity_params
        params.expect(user: [ :email_address, :password, :password_confirmation ])
      end
  end
end
