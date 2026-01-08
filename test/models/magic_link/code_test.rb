# frozen_string_literal: true

require "test_helper"

class MagicLink::CodeTest < ActiveSupport::TestCase
  test "generate creates code of specified length" do
    code = MagicLink::Code.generate(6)

    assert_equal 6, code.length
    assert_match(/\A[#{SecureRandom::BASE32_ALPHABET.join}]+\z/, code)
  end

  test "sanitize handles character substitutions" do
    # O -> 0, I -> 1, L -> 1
    assert_equal "011123", MagicLink::Code.sanitize("OIL123")
  end

  test "sanitize removes invalid characters" do
    assert_equal "ABC123", MagicLink::Code.sanitize("ABC-123 !@#")
  end

  test "sanitize handles nil and empty strings" do
    assert_nil MagicLink::Code.sanitize(nil)
    assert_nil MagicLink::Code.sanitize("")
  end

  test "sanitize converts to uppercase" do
    assert_equal "ABC123", MagicLink::Code.sanitize("abc123")
  end
end
