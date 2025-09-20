# frozen_string_literal: true

require "test_helper"

class OrganizationsHelperTest < ActionView::TestCase
  include Components::AvatarHelper
  include ComponentsHelper

  setup do
    @organization = organizations(:feedbackbin)
  end

  test "organization_logo with default size (medium)" do
    logo_html = organization_logo(@organization)

    # Avatar component uses size-8 class and square shape (rounded-md)
    assert_includes logo_html, "size-8"
    assert_includes logo_html, "rounded-md"
    # Should contain the fallback initials
    assert_includes logo_html, "FE"
    # Should not contain image tag when no logo attached
    assert_no_match(/<img/, logo_html)
  end

  test "organization_logo with large size" do
    logo_html = organization_logo(@organization, size: :lg)

    # Large size maps to :lg avatar size (size-12)
    assert_includes logo_html, "size-12"
    assert_includes logo_html, "rounded-md"
    assert_includes logo_html, "FE"
  end

  test "organization_logo with small size" do
    logo_html = organization_logo(@organization, size: :sm)

    # Small size maps to :sm avatar size (size-6)
    assert_includes logo_html, "size-6"
    assert_includes logo_html, "rounded-md"
    assert_includes logo_html, "FE"
  end

  test "organization_logo with attached logo image (large)" do
    @organization.logo.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")

    logo_html = organization_logo(@organization, size: :lg)

    # Should contain image tag
    assert_match(/<img/, logo_html)
    assert_includes logo_html, 'alt="FeedbackBin"'
    assert_includes logo_html, "racecar.jpeg"
    assert_includes logo_html, "size-12"
    assert_includes logo_html, "rounded-md"
  end

  test "organization_logo with attached logo image (medium)" do
    @organization.logo.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")

    logo_html = organization_logo(@organization, size: :default)

    assert_match(/<img/, logo_html)
    assert_includes logo_html, 'alt="FeedbackBin"'
    assert_includes logo_html, "racecar.jpeg"
    assert_includes logo_html, "size-8"
  end

  test "organization_logo with attached logo image (small)" do
    @organization.logo.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")

    logo_html = organization_logo(@organization, size: :sm)

    assert_match(/<img/, logo_html)
    assert_includes logo_html, 'alt="FeedbackBin"'
    assert_includes logo_html, "racecar.jpeg"
    assert_includes logo_html, "size-6"
  end

  test "organization_logo with custom classes" do
    logo_html = organization_logo(@organization, size: :lg, class: "custom-class")

    assert_includes logo_html, "custom-class"
    assert_includes logo_html, "size-12"
  end
end
