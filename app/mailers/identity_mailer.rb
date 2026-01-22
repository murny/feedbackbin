# frozen_string_literal: true

class IdentityMailer < ApplicationMailer
  def email_verification(identity)
    @identity = identity
    @token = @identity.generate_token_for(:email_verification)
    @url = users_email_verification_url(token: @token, script_name: "")
    mail subject: t(".verify_your_email"), to: identity.email_address
  end

  def email_change_confirmation(identity:, new_email_address:, token:)
    @identity = identity
    @new_email = new_email_address
    @url = users_email_change_confirmation_url(token: token, script_name: "")
    mail subject: t(".confirm_email_change"), to: new_email_address
  end

  def password_reset(identity)
    @identity = identity
    @token = @identity.password_reset_token
    mail subject: t(".reset_your_password"), to: identity.email_address
  end
end
