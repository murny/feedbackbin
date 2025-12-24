# frozen_string_literal: true

class MagicLinkMailer < ApplicationMailer
  def sign_in_instructions(magic_link)
    @magic_link = magic_link
    @identity = @magic_link.identity

    mail to: @identity.email_address, subject: t(".subject", code: @magic_link.code)
  end
end
