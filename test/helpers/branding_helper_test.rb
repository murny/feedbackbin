# frozen_string_literal: true

require "test_helper"

class BrandingHelperTest < ActionView::TestCase
  include BrandingHelper

  setup do
    @organization = organizations(:feedbackbin)
  end

  # branded_logo_url tests
  test "branded_logo_url returns organization logo_link when set" do
    @organization.update(logo_link: "https://example.com")

    assert_equal "https://example.com", branded_logo_url
  end

  test "branded_logo_url returns root_path when organization has no logo_link" do
    @organization.update(logo_link: nil)

    assert_equal root_path, branded_logo_url
  end

  # brand_name tests
  test "brand_name returns organization name" do
    assert_equal @organization.name, brand_name
  end

  test "brand_name returns translation when no organization" do
    Current.stub :organization, nil do
      assert_equal I18n.t("application.navbar.brand_name"), brand_name
    end
  end

  # show_brand_name? tests
  test "show_brand_name? returns true when organization wants to show name" do
    @organization.update(show_company_name: true)

    assert_predicate self, :show_brand_name?
  end

  test "show_brand_name? returns false when organization wants logo only" do
    @organization.update(show_company_name: false)

    assert_not show_brand_name?
  end

  test "show_brand_name? returns true when no organization" do
    Current.stub :organization, nil do
      assert_predicate self, :show_brand_name?
    end
  end

  # organization_og_image_url tests
  test "organization_og_image_url returns og_image URL when attached" do
    @organization.og_image.attach(
      io: file_fixture("racecar.jpeg").open,
      filename: "og-image.jpg",
      content_type: "image/jpeg"
    )

    url = organization_og_image_url(@organization)

    assert_match %r{/rails/active_storage/}, url
  end

  test "organization_og_image_url falls back to logo when no og_image" do
    @organization.logo.attach(
      io: file_fixture("racecar.jpeg").open,
      filename: "logo.jpg",
      content_type: "image/jpeg"
    )

    url = organization_og_image_url(@organization)

    assert_match %r{/rails/active_storage/}, url
  end

  test "organization_og_image_url falls back to default icon when no images" do
    url = organization_og_image_url(@organization)

    assert_includes url, "/icon.png"
  end

  # attachment_preview_url tests
  test "attachment_preview_url returns variant URL when attachment is persisted" do
    @organization.logo.attach(
      io: file_fixture("racecar.jpeg").open,
      filename: "logo.jpg",
      content_type: "image/jpeg"
    )

    url = attachment_preview_url(
      @organization.logo,
      variant_options: { resize_to_limit: [ 96, 96 ] }
    )

    assert_match %r{/rails/active_storage/representations/}, url
  end

  test "attachment_preview_url returns default URL when attachment not attached" do
    org = Organization.new(name: "Test")
    url = attachment_preview_url(org.logo, default_url: "/default.svg")

    assert_equal "/default.svg", url
  end

  test "attachment_preview_url returns default URL when attachment not persisted" do
    @organization.logo.attach(
      io: file_fixture("racecar.jpeg").open,
      filename: "logo.jpg",
      content_type: "image/jpeg"
    )

    # Stub the blob to appear unpersisted
    @organization.logo.blob.stub :persisted?, false do
      url = attachment_preview_url(@organization.logo, default_url: "/default.svg")

      assert_equal "/default.svg", url
    end
  end
end
