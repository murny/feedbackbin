# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/identity_mailer
class IdentityMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/identity_mailer/email_verification
  def email_verification
    IdentityMailer.email_verification(Identity.take)
  end

  # Preview this email at http://localhost:3000/rails/mailers/identity_mailer/password_reset
  def password_reset
    IdentityMailer.password_reset(Identity.take)
  end
end
