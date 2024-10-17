# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def email_verification(user)
    @user = user
    @token = @user.generate_token_for(:email_verification)
    mail subject: t(".verify_your_email"), to: user.email_address
  end

  def password_reset(user)
    @user = user
    mail subject: t(".reset_your_password"), to: user.email_address
  end
end
