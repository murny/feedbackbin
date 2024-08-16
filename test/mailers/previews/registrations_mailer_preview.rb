# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/registrations_mailer
class RegistrationsMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/registrations_mailer/email_verification
  def reset
    RegistrationsMailer.email_verification(User.take)
  end
end
