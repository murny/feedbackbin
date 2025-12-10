# frozen_string_literal: true

module Users
  class RegistrationsController < ApplicationController
    allow_unauthenticated_access
    skip_after_action :verify_authorized

    rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to sign_up_path, alert: t("users.registrations.create.rate_limited") }

    def new
      @user = User.new
      @invitation = Invitation.find_by(token: params[:invitation_token]) if params[:invitation_token]

      if @invitation
        # Pre-fill form with invitation data
        @user.email_address = @invitation.email
        @user.name = @invitation.name
      end
    end

    def create
      @user = User.new(user_params)
      @user.role = :member # Always create as member

      # Check for invitation
      @invitation = Invitation.find_by(token: params[:invitation_token]) if params[:invitation_token]

      if @user.save
        # Auto-verify email for invited users
        if @invitation
          @invitation.accept!(@user)
        else
          UserMailer.email_verification(@user).deliver_later
        end

        start_new_session_for(@user)

        redirect_to root_path, notice: t(".signed_up_successfully")
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

      def user_params
        params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
      end
  end
end
