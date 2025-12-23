# frozen_string_literal: true

require "test_helper"

class MagicLinkTest < ActiveSupport::TestCase
  test "creates magic link with code and expiration" do
    identity = identities(:jane)
    magic_link = MagicLink.create!(identity: identity)

    assert magic_link.code.present?
    assert_equal MagicLink::CODE_LENGTH, magic_link.code.length
    assert magic_link.expires_at.present?
    assert_in_delta MagicLink::EXPIRATION_TIME.from_now, magic_link.expires_at, 1.second
  end

  test "active scope returns non-expired links" do
    active_link = magic_links(:valid)
    expired_link = magic_links(:expired)

    assert_includes MagicLink.active, active_link
    assert_not_includes MagicLink.active, expired_link
  end

  test "stale scope returns expired links" do
    active_link = magic_links(:valid)
    expired_link = magic_links(:expired)

    assert_includes MagicLink.stale, expired_link
    assert_not_includes MagicLink.stale, active_link
  end

  test "consume finds and destroys active magic link" do
    magic_link = magic_links(:valid)
    code_with_spaces = magic_link.code.downcase.chars.join(" ")

    consumed_magic_link = MagicLink.consume(code_with_spaces)

    assert_equal magic_link.identity_id, consumed_magic_link.identity_id
    assert_not MagicLink.exists?(magic_link.id)
  end

  test "consume returns nil for expired links" do
    expired_link = magic_links(:expired)

    assert_nil MagicLink.consume(expired_link.code)
    assert MagicLink.exists?(expired_link.id)
  end

  test "consume returns nil for invalid codes" do
    assert_nil MagicLink.consume("INVALID")
    assert_nil MagicLink.consume(nil)
  end

  test "cleanup removes stale magic links" do
    active_link = magic_links(:valid)
    expired_link = magic_links(:expired)

    MagicLink.cleanup

    assert MagicLink.exists?(active_link.id)
    assert_not MagicLink.exists?(expired_link.id)
  end

  test "purpose enum" do
    sign_in_link = magic_links(:valid)
    sign_up_link = magic_links(:sign_up)

    assert sign_in_link.for_sign_in?
    assert_not sign_in_link.for_sign_up?

    assert sign_up_link.for_sign_up?
    assert_not sign_up_link.for_sign_in?
  end
end
