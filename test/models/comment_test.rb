# frozen_string_literal: true

require "test_helper"

class CommentTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:shane_chrome)
    @comment = comments(:one)
  end

  test "valid comment" do
    assert_predicate @comment, :valid?
  end

  test "invalid without body" do
    @comment.body = nil

    assert_not @comment.valid?
    assert_equal "can't be blank", @comment.errors[:body].first
  end

  test "invalid without idea" do
    @comment.idea = nil

    assert_not @comment.valid?
    assert_equal "must exist", @comment.errors[:idea].first
  end

  test "invalid without creator" do
    # Stub the default current user to nil so we can test the validation
    Current.stubs(:user).returns(nil)
    @comment.creator = nil

    assert_not @comment.valid?
    assert_equal "must exist", @comment.errors[:creator].first
  end

  test "should be able to create a reply to a comment" do
    @reply = Comment.create(body: "Hello, world!", idea: @comment.idea, parent: @comment, creator: users(:shane))

    assert_predicate @reply, :valid?

    assert_equal @comment, @reply.parent
    assert_equal @comment.idea, @reply.idea
    assert_equal 1, @comment.replies.count
    assert_equal @reply, @comment.replies.first
  end

  test "creating a comment increments the idea's comments_count" do
    idea = @comment.idea

    assert_difference -> { idea.reload.comments_count }, 1 do
      idea.comments.create!(body: "Another comment", creator: users(:shane))
    end
  end

  test "destroying a comment decrements the idea's comments_count" do
    idea = @comment.idea

    assert_difference -> { idea.reload.comments_count }, -1 do
      @comment.destroy!
    end
  end

  test "destroying a comment with replies decrements comments_count for the comment and its replies" do
    idea = @comment.idea
    @comment.replies.create!(body: "A reply", idea: idea, creator: users(:shane))

    expected = -idea.comments.where(id: [ @comment.id ] + @comment.replies.ids).count

    assert_difference -> { idea.reload.comments_count }, expected do
      @comment.destroy!
    end
  end

  test "should not allow replies to replies (max 1 level nesting)" do
    reply = comments(:reply_one)

    nested_reply = Comment.new(body: "Nested reply", idea: reply.idea, parent: reply, creator: users(:shane))

    assert_not nested_reply.valid?
    assert_includes nested_reply.errors[:parent_id], "you can only reply to comments, not to other replies"
  end

  test "should allow reply to top-level comment" do
    top_level_comment = comments(:one)

    reply = Comment.new(body: "Valid reply", idea: top_level_comment.idea, parent: top_level_comment, creator: users(:shane))

    assert_predicate reply, :valid?
  end

  test "parent_id is readonly after creation" do
    reply = comments(:reply_one)
    other_top_level = comments(:two)

    assert_raises(ActiveRecord::ReadonlyAttributeError) do
      reply.update(parent_id: other_top_level.id)
    end
  end

  test "should not allow reply to comment from different idea" do
    comment_on_idea_one = comments(:one)
    different_idea = ideas(:two)

    reply = Comment.new(body: "Cross-idea reply", idea: different_idea, parent: comment_on_idea_one, creator: users(:shane))

    assert_not reply.valid?
    assert_includes reply.errors[:parent_id], "must belong to the same idea"
  end

  test "creates event when regular user creates comment" do
    assert_difference "Event.count", 1 do
      Comment.create!(body: "User comment", idea: ideas(:one), creator: users(:shane))
    end
  end

  test "does not create event when system user creates comment" do
    assert_no_difference "Event.count" do
      Comment.create!(body: "System comment", idea: ideas(:one), creator: users(:system))
    end
  end

  test "auto-watches idea when user comments" do
    idea = ideas(:two)
    user = users(:shane)

    assert_not idea.watched_by?(user)

    Comment.create!(body: "Great idea!", idea: idea, creator: user)

    assert idea.reload.watched_by?(user)
  end

  test "auto-watch is idempotent for existing watchers" do
    idea = ideas(:one)
    user = users(:shane)

    assert idea.watched_by?(user)

    assert_no_difference "Watch.count" do
      Comment.create!(body: "Another comment", idea: idea, creator: user)
    end

    assert idea.watched_by?(user)
  end

  test "sorted_by returns comments in oldest order by default" do
    idea = ideas(:one)
    comments = idea.comments.where(parent_id: nil).sorted_by(nil)

    assert_equal comments.first.created_at, comments.minimum(:created_at)
  end

  test "sorted_by newest returns comments in newest first order" do
    idea = ideas(:one)
    comments = idea.comments.where(parent_id: nil).sorted_by(:newest)

    assert_equal comments.first.created_at, comments.maximum(:created_at)
  end

  test "sorted_by top returns comments ordered by votes_count descending" do
    idea = ideas(:one)
    comments = idea.comments.where(parent_id: nil).sorted_by(:top)

    assert_operator comments.first.votes_count, :>=, comments.last.votes_count
  end

  test "destroying a comment clears official_comment references on ideas" do
    idea = @comment.idea
    idea.update!(official_comment: @comment)

    @comment.destroy!

    assert_nil idea.reload.official_comment_id
  end

  test "comments are scoped to their account via association" do
    feedbackbin_comment = comments(:one)

    assert_includes accounts(:feedbackbin).comments, feedbackbin_comment
    assert_not_includes accounts(:acme).comments, feedbackbin_comment
  end

  test "acme account scope cannot find a feedbackbin comment" do
    feedbackbin_comment = comments(:one)

    assert_raises(ActiveRecord::RecordNotFound) do
      accounts(:acme).comments.find(feedbackbin_comment.id)
    end
  end

  test "edited? returns false when edited_at is nil" do
    assert_nil @comment.edited_at
    assert_not @comment.edited?
  end

  test "edited? returns true when edited_at is set" do
    @comment.edited_at = Time.current

    assert_predicate @comment, :edited?
  end

  test "new Comment has internal false by default" do
    refute Comment.new.internal
  end

  test "public_only scope excludes internal comments" do
    assert_empty Comment.public_only.where(id: comments(:internal_one).id)
    assert_includes Comment.public_only.where(id: comments(:one).id), comments(:one)
  end

  test "internal_only scope returns only internal comments" do
    assert_includes Comment.internal_only.where(id: comments(:internal_one).id), comments(:internal_one)
    assert_empty Comment.internal_only.where(id: comments(:one).id)
  end

  test "visible_to admin returns internal comments" do
    visible = Comment.visible_to(users(:admin)).where(id: comments(:internal_one).id)

    assert_includes visible, comments(:internal_one)
  end

  test "visible_to owner returns internal comments" do
    visible = Comment.visible_to(users(:shane)).where(id: comments(:internal_one).id)

    assert_includes visible, comments(:internal_one)
  end

  test "visible_to member returns only public comments" do
    visible_ids = Comment.visible_to(users(:jane)).where(id: [ comments(:one).id, comments(:internal_one).id ]).ids

    assert_includes visible_ids, comments(:one).id
    assert_not_includes visible_ids, comments(:internal_one).id
  end

  test "visible_to nil returns only public comments" do
    visible_ids = Comment.visible_to(nil).where(id: [ comments(:one).id, comments(:internal_one).id ]).ids

    assert_includes visible_ids, comments(:one).id
    assert_not_includes visible_ids, comments(:internal_one).id
  end

  test "creating an internal comment does not increment idea.comments_count" do
    idea = @comment.idea

    assert_no_difference -> { idea.reload.comments_count } do
      idea.comments.create!(body: "Internal note", creator: users(:shane), internal: true)
    end
  end

  test "destroying an internal comment does not decrement idea.comments_count" do
    idea = @comment.idea
    internal = idea.comments.create!(body: "Internal note", creator: users(:shane), internal: true)
    baseline = idea.reload.comments_count

    assert_no_difference -> { idea.reload.comments_count } do
      internal.destroy!
    end

    assert_equal baseline, idea.reload.comments_count
  end

  test "non-admin cannot reply to an internal comment" do
    internal = comments(:internal_one)
    reply = Comment.new(
      body: "Public reply to internal",
      idea: internal.idea,
      parent: internal,
      creator: users(:jane)
    )

    assert_not reply.valid?, "Expected validation to reject a non-admin reply under an internal parent (WR-03)"
    assert_includes reply.errors[:parent_id], I18n.t("activerecord.errors.models.comment.attributes.parent_id.cannot_reply_to_internal")
  end

  test "admin can reply to an internal comment" do
    internal = comments(:internal_one)
    reply = Comment.new(
      body: "Admin reply to internal",
      idea: internal.idea,
      parent: internal,
      creator: users(:admin)
    )

    assert_predicate reply, :valid?
  end
end
