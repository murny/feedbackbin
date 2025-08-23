# frozen_string_literal: true

require "test_helper"

class OrganizationsHelperTest < ActionView::TestCase
  setup do
    @organization = organizations(:feedbackbin)
    @organization_with_logo = organizations(:company)
  end

  test "organization_logo with large size (default)" do
    logo_html = organization_logo(@organization)

    assert_includes logo_html, 'class="size-12 rounded-lg bg-primary text-primary-foreground text-sm font-medium flex items-center justify-center"'
    assert_includes logo_html, "FE"
    assert_no_match(/img/, logo_html) # Should not contain image tag
  end

  test "organization_logo with medium size" do
    logo_html = organization_logo(@organization, size: :medium)

    assert_includes logo_html, 'class="h-5 w-5 rounded-sm bg-muted text-muted-foreground text-xs font-medium flex items-center justify-center flex-shrink-0"'
    assert_includes logo_html, "FE"
  end

  test "organization_logo with small size" do
    logo_html = organization_logo(@organization, size: :small)

    assert_includes logo_html, 'class="h-4 w-4 rounded-sm bg-muted text-muted-foreground text-xs font-medium flex items-center justify-center flex-shrink-0"'
    assert_includes logo_html, "FE"
  end

  test "organization_logo with attached logo image (large)" do
    @organization.logo.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")

    logo_html = organization_logo(@organization, size: :large)

    assert_match(/img/, logo_html)
    assert_includes logo_html, 'class="rounded-lg size-12 object-cover"'
    assert_includes logo_html, 'alt="FeedbackBin"'
    assert_includes logo_html, "racecar.jpeg"
  end

  test "organization_logo with attached logo image (medium)" do
    @organization.logo.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")

    logo_html = organization_logo(@organization, size: :medium)

    assert_match(/img/, logo_html)
    assert_includes logo_html, 'class="h-5 w-5 rounded-sm object-cover flex-shrink-0"'
    assert_includes logo_html, 'alt="FeedbackBin"'
    assert_includes logo_html, "racecar.jpeg"
  end

  test "organization_logo with attached logo image (small)" do
    @organization.logo.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")

    logo_html = organization_logo(@organization, size: :small)

    assert_match(/img/, logo_html)
    assert_includes logo_html, 'class="h-4 w-4 rounded-sm object-cover flex-shrink-0"'
    assert_includes logo_html, 'alt="FeedbackBin"'
    assert_includes logo_html, "racecar.jpeg"
  end

  test "organization_logo with custom classes" do
    logo_html = organization_logo(@organization, size: :large, class: "custom-class")

    assert_includes logo_html, "size-12 rounded-lg bg-primary text-primary-foreground text-sm font-medium flex items-center justify-center custom-class"
  end

  test "organization_logo raises error for invalid size" do
    assert_raises(ArgumentError, "Unknown logo size: invalid. Use :small, :medium, or :large") do
      organization_logo(@organization, size: :invalid)
    end
  end
end
