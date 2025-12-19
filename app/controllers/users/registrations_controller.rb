# frozen_string_literal: true

module Users
  class RegistrationsController < ApplicationController
    allow_unauthenticated_access
    skip_after_action :verify_authorized

    rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to sign_up_path, alert: t("users.registrations.create.rate_limited") }

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

      ActiveRecord::Base.transaction do
        @identity = Identity.new(identity_params)
        @identity.save!

        # Set account context - use invitation's account or first account for self-registration
        Current.account = @invitation&.account || Account.first

        @user = User.new(user_params)
        @user.identity = @identity
        @user.role = :member
        @user.save!

        # Auto-verify email for invited users
        if @invitation
          @invitation.accept!(@user)
        else
          IdentityMailer.email_verification(@identity).deliver_later
        end

        start_new_session_for(@identity)
      end

      redirect_to root_path, notice: t(".signed_up_successfully")
    rescue ActiveRecord::RecordInvalid
      @identity ||= Identity.new(identity_params)
      @user ||= User.new(user_params)
      render :new, status: :unprocessable_entity
    end

    private

      def user_params
        params.expect(user: [ :name ])
      end

      def identity_params
        params.expect(user: [ :email_address, :password, :password_confirmation ])
      end
  end
end
