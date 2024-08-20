# frozen_string_literal: true

class Users::RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      start_new_session_for(@user)

      UsersMailer.email_verification(@user).deliver_later

      redirect_to root_path, notice: t(".signed_up_successfully")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:name, :email_address, :password, :password_confirmation)
  end
end
