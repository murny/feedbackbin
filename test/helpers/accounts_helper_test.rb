# frozen_string_literal: true

require "test_helper"

class AccountsHelperTest < ActionView::TestCase
  setup do
    @account = accounts(:feedbackbin)
  end

  test "account_logo with default size (medium)" do
    logo_html = account_logo(@account)

    # Avatar component uses size-8 class and square shape (rounded-md)
    assert_includes logo_html, "size-8"
    assert_includes logo_html, "rounded-md"
    # Should contain the fallback initials
    assert_includes logo_html, "FE"
    # Should not contain image tag when no logo attached
    assert_no_match(/<img/, logo_html)
  end

  test "account_logo with large size" do
    logo_html = account_logo(@account, size: :lg)

    # Large size maps to :lg avatar size (size-12)
    assert_includes logo_html, "size-12"
    assert_includes logo_html, "rounded-md"
    assert_includes logo_html, "FE"
  end

  test "account_logo with small size" do
    logo_html = account_logo(@account, size: :sm)

    # Small size maps to :sm avatar size (size-6)
    assert_includes logo_html, "size-6"
    assert_includes logo_html, "rounded-md"
    assert_includes logo_html, "FE"
  end

  test "account_logo with attached logo image (large)" do
    @account.logo.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")

    logo_html = account_logo(@account, size: :lg)

    # Should contain image tag
    assert_match(/<img/, logo_html)
    assert_includes logo_html, 'alt="FeedbackBin"'
    assert_includes logo_html, "racecar.jpeg"
    assert_includes logo_html, "size-12"
    assert_includes logo_html, "rounded-md"
  end

  test "account_logo with attached logo image (medium)" do
    @account.logo.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")

    logo_html = account_logo(@account, size: :default)

    assert_match(/<img/, logo_html)
    assert_includes logo_html, 'alt="FeedbackBin"'
    assert_includes logo_html, "racecar.jpeg"
    assert_includes logo_html, "size-8"
  end

  test "account_logo with attached logo image (small)" do
    @account.logo.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")

    logo_html = account_logo(@account, size: :sm)

    assert_match(/<img/, logo_html)
    assert_includes logo_html, 'alt="FeedbackBin"'
    assert_includes logo_html, "racecar.jpeg"
    assert_includes logo_html, "size-6"
  end

  test "account_logo with custom classes" do
    logo_html = account_logo(@account, size: :lg, class: "custom-class")

    assert_includes logo_html, "custom-class"
    assert_includes logo_html, "size-12"
  end
end
