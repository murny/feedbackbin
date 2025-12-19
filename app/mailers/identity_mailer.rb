# frozen_string_literal: true

class IdentityMailer < ApplicationMailer
  def email_verification(identity)
    @identity = identity
    @token = @identity.generate_token_for(:email_verification)
    mail subject: t(".verify_your_email"), to: identity.email_address
  end

  def password_reset(identity)
    @identity = identity
    @token = @identity.generate_token_for(:password_reset)
    mail subject: t(".reset_your_password"), to: identity.email_address
  end
end
