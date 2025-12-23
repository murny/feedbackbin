# frozen_string_literal: true

require "test_helper"

class BrandingHelperTest < ActionView::TestCase
  include BrandingHelper

  setup do
    @account = accounts(:feedbackbin)
  end

  # branded_logo_url tests
  test "branded_logo_url returns account logo_link when set" do
    @account.update(logo_link: "https://example.com")

    assert_equal "https://example.com", branded_logo_url
  end

  test "branded_logo_url returns root_path when account has no logo_link" do
    @account.update(logo_link: nil)

    assert_equal root_path, branded_logo_url
  end

  # brand_name tests
  test "brand_name returns account name" do
    assert_equal @account.name, brand_name
  end

  test "brand_name returns translation when no account" do
    Current.stubs(:account).returns(nil)

    assert_equal I18n.t("application.navbar.brand_name"), brand_name
  end

  # show_brand_name? tests
  test "show_brand_name? returns true when account wants to show name" do
    @account.update(show_company_name: true)

    assert_predicate self, :show_brand_name?
  end

  test "show_brand_name? returns false when account wants logo only" do
    @account.update(show_company_name: false)

    assert_not show_brand_name?
  end

  test "show_brand_name? returns true when no account" do
    Current.stubs(:account).returns(nil)

    assert_predicate self, :show_brand_name?
  end

  # account_og_image_url tests
  test "account_og_image_url returns og_image URL when attached" do
    @account.og_image.attach(
      io: file_fixture("racecar.jpeg").open,
      filename: "og-image.jpg",
      content_type: "image/jpeg"
    )

    url = account_og_image_url(@account)

    assert_match %r{/rails/active_storage/}, url
  end

  test "account_og_image_url falls back to logo when no og_image" do
    @account.logo.attach(
      io: file_fixture("racecar.jpeg").open,
      filename: "logo.jpg",
      content_type: "image/jpeg"
    )

    url = account_og_image_url(@account)

    assert_match %r{/rails/active_storage/}, url
  end

  test "account_og_image_url falls back to default icon when no images" do
    url = account_og_image_url(@account)

    assert_includes url, "/icon.png"
  end

  # attachment_preview_url tests
  test "attachment_preview_url returns variant URL when attachment is persisted" do
    @account.logo.attach(
      io: file_fixture("racecar.jpeg").open,
      filename: "logo.jpg",
      content_type: "image/jpeg"
    )

    url = attachment_preview_url(
      @account.logo,
      variant_options: { resize_to_limit: [ 96, 96 ] }
    )

    assert_match %r{/rails/active_storage/representations/}, url
  end

  test "attachment_preview_url returns default URL when attachment not attached" do
    acc = Account.new(name: "Test")
    url = attachment_preview_url(acc.logo, default_url: "/default.svg")

    assert_equal "/default.svg", url
  end

  test "attachment_preview_url returns default URL when attachment not persisted" do
    @account.logo.attach(
      io: file_fixture("racecar.jpeg").open,
      filename: "logo.jpg",
      content_type: "image/jpeg"
    )

    # Stub the blob to appear unpersisted
    @account.logo.blob.stubs(:persisted?).returns(false)
    url = attachment_preview_url(@account.logo, default_url: "/default.svg")

    assert_equal "/default.svg", url
  end
end
