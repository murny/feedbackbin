# frozen_string_literal: true

module Identity::EmailAddressChangeable
  EMAIL_CHANGE_TOKEN_PURPOSE = "change_email_address"
  EMAIL_CHANGE_TOKEN_EXPIRATION = 30.minutes

  extend ActiveSupport::Concern

  def send_email_address_change_confirmation(new_email_address)
    token = generate_email_address_change_token(to: new_email_address)

    IdentityMailer.email_change_confirmation(
      identity: self,
      new_email_address: new_email_address,
      token: token
    ).deliver_later
  end

  def change_email_address_using_token(token)
    parsed_token = SignedGlobalID.parse(token, for: EMAIL_CHANGE_TOKEN_PURPOSE)

    old_email_address = parsed_token&.params&.fetch("old_email_address")
    new_email_address = parsed_token&.params&.fetch("new_email_address")

    if parsed_token.nil? || parsed_token.find != self || email_address != old_email_address
      false
    else
      change_email_address(new_email_address)
    end
  end

  def change_email_address(new_email_address)
    update!(email_address: new_email_address, email_verified_at: Time.current)
  end

  private
    def generate_email_address_change_token(to:, from: email_address)
      to_sgid(
        for: EMAIL_CHANGE_TOKEN_PURPOSE,
        expires_in: EMAIL_CHANGE_TOKEN_EXPIRATION,
        old_email_address: from,
        new_email_address: to
      ).to_s
    end
end
