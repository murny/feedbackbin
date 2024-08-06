# frozen_string_literal: true

class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: t("passwords_mailer.reset.reset_your_password"), to: user.email_address, from: "passwords@example.com"
  end
end
