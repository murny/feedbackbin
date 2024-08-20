# frozen_string_literal: true

class UsersMailer < ApplicationMailer
  def email_verification(user)
    @user = user
    mail subject: t(".verify_your_email"), to: user.email_address
  end

  def password_reset(user)
    @user = user
    mail subject: t(".reset_your_password"), to: user.email_address
  end
end
