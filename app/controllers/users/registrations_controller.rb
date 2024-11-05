# frozen_string_literal: true

module Users
  class RegistrationsController < ApplicationController
    allow_unauthenticated_access
    skip_after_action :verify_authorized

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)

      if @user.save
        start_new_session_for(@user)

        UserMailer.email_verification(@user).deliver_later

        redirect_to root_path, notice: t(".signed_up_successfully")
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:username, :name, :email_address, :password, :password_confirmation)
    end
  end
end
