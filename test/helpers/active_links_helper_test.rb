require "test_helper"

class ActiveLinksHelperTest < ActionView::TestCase
  test "it works with an absolute url" do
    absolute_link = active_link_to("FeedbackBin", "https://feedbackbin.com")

    assert_equal '<a href="https://feedbackbin.com">FeedbackBin</a>', absolute_link
  end

  test "accepts classes" do
    link_with_classes = active_link_to("Link with Classes", "/link-with-classes", class: "link-primary")

    assert_equal '<a class="link-primary" href="/link-with-classes">Link with Classes</a>', link_with_classes
  end

  test "accepts data attributes" do
    link_with_data_attrs = active_link_to(
      "Link with data attrs",
      "/link-with-data-attrs",
      class: "link-primary",
      data: {test: "foo"}
    )

    assert_equal '<a class="link-primary" data-test="foo" href="/link-with-data-attrs">Link with data attrs</a>', link_with_data_attrs
  end

  test "accepts blocks" do
    block_link = active_link_to("/block") { "Block Link" }

    assert_equal '<a href="/block">Block Link</a>', block_link
  end

  test "accepts blocks with classes" do
    block_link = active_link_to("/block-class", class: "link-primary") { "Block Link with Classes" }

    assert_equal '<a class="link-primary" href="/block-class">Block Link with Classes</a>', block_link
  end

  test "adds an active class by default when on active page" do
    request.path = "/active-page"
    active_link = active_link_to("Link active", "/active-page")

    assert_equal '<a class="active" href="/active-page">Link active</a>', active_link
  end

  test "adds custom active class when on active page" do
    request.path = "/active-page"
    active_link_with_active_class = active_link_to(
      "Custom active class",
      "/active-page",
      active_class: "custom-active-class"
    )

    assert_equal '<a class="custom-active-class" href="/active-page">Custom active class</a>', active_link_with_active_class
  end

  test "add custom inactive class when not on active page" do
    active_link_with_inactive_class = active_link_to(
      "Custom inactive class",
      "/not-active-page",
      inactive_class: "custom-inactive-class"
    )

    assert_equal '<a class="custom-inactive-class" href="/not-active-page">Custom inactive class</a>', active_link_with_inactive_class
  end

  test "adds active class when on a page that starts with the starts_with option" do
    request.path = "/posts/1/comments/1"
    starts_with_link = active_link_to("Starts with", "/starts", starts_with: "/posts")

    assert_equal '<a class="active" href="/starts">Starts with</a>', starts_with_link
  end
end
