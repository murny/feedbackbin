# frozen_string_literal: true

require "test_helper"

class Idea::Eventable::SystemCommenterTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:shane_chrome)
    @idea = ideas(:one)
  end

  test "idea_status_changed" do
    assert_system_comment 'Shane changed the status from "Open" to "In Progress"' do
      @idea.update!(status: statuses(:in_progress))
    end
  end

  test "idea_board_changed" do
    assert_system_comment 'Shane moved this from "Feature Requests" to "Bug Reports"' do
      @idea.update!(board: boards(:two))
    end
  end

  test "idea_title_changed" do
    assert_system_comment 'Shane changed the title from "Wish this had dark mode!" to "Please add dark mode"' do
      @idea.update!(title: "Please add dark mode")
    end
  end

  test "idea_created does not create system comment" do
    assert_no_difference -> { Comment.count } do
      idea = Idea.create!(
        title: "New idea",
        board: boards(:one),
        account: accounts(:feedbackbin),
        creator: users(:shane)
      )

      assert_not idea.comments.exists?(creator: idea.account.system_user)
    end
  end

  test "escapes html in comment body" do
    users(:shane).update!(name: "<em>Injected</em>")
    Current.session = sessions(:shane_chrome)

    assert_difference -> { @idea.comments.count }, 1 do
      @idea.update!(status: statuses(:in_progress))
    end

    comment = @idea.comments.last
    html = comment.body.body.to_html

    assert_includes html, "&lt;em&gt;Injected&lt;/em&gt;"
    assert_not_includes html, "<em>Injected</em>"
  end

  test "does not notify on system comments" do
    @idea.watch_by(users(:shane))

    assert_no_difference -> { Notification.count } do
      @idea.update!(status: statuses(:in_progress))
    end
  end

  private

    def assert_system_comment(expected_comment)
      assert_difference -> { @idea.comments.count }, 1 do
        yield
        comment = @idea.comments.last

        assert_predicate comment.creator, :system?
        # Use plain text for comparison
        plain_text = comment.body.to_plain_text.strip

        assert_match Regexp.new(Regexp.escape(expected_comment), Regexp::IGNORECASE), plain_text
      end
    end
end
