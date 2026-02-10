# frozen_string_literal: true

require "test_helper"

class AccountsHelperTest < ActionView::TestCase
  setup do
    @account = accounts(:feedbackbin)
  end

  test "account_logo with default size (medium)" do
    logo_html = account_logo(@account)

    assert_includes logo_html, "avatar"
    assert_includes logo_html, "avatar--square"
    assert_includes logo_html, "FE"
    assert_no_match(/<img/, logo_html)
  end

  test "account_logo with large size" do
    logo_html = account_logo(@account, size: :lg)

    assert_includes logo_html, "avatar--lg"
    assert_includes logo_html, "avatar--square"
    assert_includes logo_html, "FE"
  end

  test "account_logo with small size" do
    logo_html = account_logo(@account, size: :sm)

    assert_includes logo_html, "avatar--sm"
    assert_includes logo_html, "avatar--square"
    assert_includes logo_html, "FE"
  end

  test "account_logo with attached logo image (large)" do
    @account.logo.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")

    logo_html = account_logo(@account, size: :lg)

    assert_match(/<img/, logo_html)
    assert_includes logo_html, 'alt="FeedbackBin"'
    assert_includes logo_html, "racecar.jpeg"
    assert_includes logo_html, "avatar--lg"
    assert_includes logo_html, "avatar--square"
  end

  test "account_logo with attached logo image (medium)" do
    @account.logo.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")

    logo_html = account_logo(@account, size: :default)

    assert_match(/<img/, logo_html)
    assert_includes logo_html, 'alt="FeedbackBin"'
    assert_includes logo_html, "racecar.jpeg"
    assert_includes logo_html, "avatar"
  end

  test "account_logo with attached logo image (small)" do
    @account.logo.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")

    logo_html = account_logo(@account, size: :sm)

    assert_match(/<img/, logo_html)
    assert_includes logo_html, 'alt="FeedbackBin"'
    assert_includes logo_html, "racecar.jpeg"
    assert_includes logo_html, "avatar--sm"
  end

  test "account_logo with custom classes" do
    logo_html = account_logo(@account, size: :lg, class: "custom-class")

    assert_includes logo_html, "custom-class"
    assert_includes logo_html, "avatar--lg"
  end
end
