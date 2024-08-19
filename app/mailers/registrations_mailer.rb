# frozen_string_literal: true

class RegistrationsMailer < ApplicationMailer
  def email_verification(user)
    @user = user
    mail subject: t(".verify_your_email"), to: user.email_address
  end
end
