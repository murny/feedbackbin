# frozen_string_literal: true

module Users
  class RegistrationsController < ApplicationController
    allow_unauthenticated_access
    skip_after_action :verify_authorized

    rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to sign_up_path, alert: t("users.registrations.create.rate_limited") }

    def new
      @identity = Identity.new
      @invitation = Invitation.find_by(token: params[:invitation_token]) if params[:invitation_token]

      if @invitation
        # Pre-fill form with invitation data
        @identity.email_address = @invitation.email
        @user_name = @invitation.name
      end
    end

    def create
      @invitation = Invitation.find_by(token: params[:invitation_token]) if params[:invitation_token]

      Identity.transaction do
        @identity = Identity.new(identity_params)

        if @identity.save
          if @invitation
            # Create user in the invited account
            user = @identity.users.create!(
              account: @invitation.account,
              name: params[:user][:name],
              role: :member,
              email_verified: true
            )
            @invitation.accept!(user)
            start_new_session_for(@identity, account: @invitation.account)
          else
            # For new signups without invitation, send verification email
            # Note: User will need to create/join an account after verification
            IdentityMailer.email_verification(@identity).deliver_later
            start_new_session_for(@identity)
          end

          redirect_to root_path, notice: t(".signed_up_successfully")
        else
          render :new, status: :unprocessable_entity
        end
      end
    end

    private

      def identity_params
        params.expect(identity: [ :email_address, :password, :password_confirmation ])
      end
  end
end
