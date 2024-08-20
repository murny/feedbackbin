# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/users_mailer
class UsersMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/registrations_mailer/email_verification
  def email_verification
    RegistrationsMailer.email_verification(User.take)
  end

  # Preview this email at http://localhost:3000/rails/mailers/users_mailer/password_reset
  def password_reset
    UsersMailer.password_reset(User.take)
  end
end
