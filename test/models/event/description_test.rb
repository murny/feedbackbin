# frozen_string_literal: true

require "test_helper"

class Event::DescriptionTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:shane_chrome)
  end

  test "generates html description for idea created event" do
    description = events(:idea_created).description_for(users(:shane))

    assert_includes description.to_html, I18n.t("events.actions.created")
    assert_includes description.to_html, ideas(:one).title
  end

  test "generates plain text description for idea created event" do
    description = events(:idea_created).description_for(users(:shane))

    assert_includes description.to_plain_text, "Shane"
    assert_includes description.to_plain_text, I18n.t("events.actions.created")
    assert_includes description.to_plain_text, ideas(:one).title
  end

  test "generates description for comment event" do
    description = events(:comment_created).description_for(users(:shane))

    assert_includes description.to_plain_text, "Jane"
    assert_includes description.to_plain_text, I18n.t("events.actions.commented_on")
  end

  test "generates description for status changed event" do
    description = events(:idea_status_changed).description_for(users(:shane))

    assert_includes description.to_plain_text, I18n.t("events.actions.changed_status")
    assert_includes description.to_html, "In Progress"
  end

  test "generates description for title changed event" do
    description = events(:idea_title_changed).description_for(users(:shane))

    assert_includes description.to_plain_text, I18n.t("events.actions.changed_title")
    assert_includes description.to_plain_text, "Old Title"
    assert_includes description.to_plain_text, "New Title"
  end

  test "generates description for board changed event" do
    description = events(:idea_board_changed).description_for(users(:shane))

    assert_includes description.to_plain_text, I18n.t("events.actions.moved")
    assert_includes description.to_html, "Bug Reports"
  end

  test "uses creator name in plain text" do
    description = events(:idea_created).description_for(users(:jane))

    assert_includes description.to_plain_text, "Shane"
  end

  test "html includes creator name with data attributes" do
    description = events(:idea_created).description_for(users(:jane))

    assert_includes description.to_html, "Shane"
    assert_includes description.to_html, "data-creator-id"
  end

  test "escapes html in idea titles in plain text description" do
    idea = ideas(:one)
    idea.update_column(:title, "<script>alert('xss')</script>")

    description = events(:idea_created).description_for(users(:shane))

    assert_includes description.to_plain_text, "&lt;script&gt;"
    assert_not_includes description.to_plain_text, "<script>"
  end

  test "escapes html in idea titles in html description" do
    idea = ideas(:one)
    idea.update_column(:title, "<script>alert('xss')</script>")

    description = events(:idea_created).description_for(users(:shane))

    assert_includes description.to_html, "&lt;script&gt;"
    assert_not_includes description.to_html, "<script>alert"
  end

  test "escapes html in creator names" do
    users(:shane).update_column(:name, "<em>Injected</em>")

    description = events(:idea_created).description_for(users(:jane))

    assert_includes description.to_plain_text, "&lt;em&gt;"
    assert_not_includes description.to_plain_text, "<em>"
  end

  test "escapes html in status names" do
    event = events(:idea_status_changed)
    event.update!(particulars: { old_status: "Open", new_status: "<script>xss</script>" })

    description = event.description_for(users(:shane))

    assert_includes description.to_html, "&lt;script&gt;"
    assert_not_includes description.to_html, "<script>xss"
  end

  test "escapes html in old and new titles" do
    event = events(:idea_title_changed)
    event.update!(particulars: { old_title: "<b>old</b>", new_title: "<i>new</i>" })

    description = event.description_for(users(:shane))

    assert_includes description.to_html, "&lt;b&gt;"
    assert_includes description.to_html, "&lt;i&gt;"
    assert_not_includes description.to_html, "<b>old"
    assert_not_includes description.to_html, "<i>new"
  end
end
