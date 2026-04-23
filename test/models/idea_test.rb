# frozen_string_literal: true

require "test_helper"

class IdeaTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:shane_chrome)
    @idea = ideas(:one)
  end

  test "valid idea" do
    assert_predicate @idea, :valid?
  end

  test "invalid without a title" do
    @idea.title = nil

    assert_not @idea.valid?
    assert_equal "can't be blank", @idea.errors[:title].first
  end

  test "invalid without a creator" do
    # Stub the default current user to nil so we can test the validation
    Current.stubs(:user).returns(nil)
    @idea.creator = nil

    assert_not @idea.valid?
    assert_equal "must exist", @idea.errors[:creator].first
  end

  test "invalid without a board" do
    @idea.board = nil

    assert_not @idea.valid?
    assert_equal "must exist", @idea.errors[:board].first
  end

  test "valid without a status (nil means Open)" do
    @idea.status = nil

    assert_predicate @idea, :valid?
    assert_predicate @idea, :open?
    assert_equal "Open", @idea.status_name
  end

  test "new idea without status is Open by default" do
    idea = Idea.create!(
      title: "Test",
      creator: users(:shane),
      board: boards(:one)
    )

    # nil status means "Open"
    assert_nil idea.status
    assert_predicate idea, :open?
    assert_equal "Open", idea.status_name
    assert_equal "#3b82f6", idea.status_color
  end

  test "idea with status uses that status" do
    idea = Idea.create!(
      title: "Test",
      creator: users(:shane),
      board: boards(:one),
      status: statuses(:planned)
    )

    assert_not_nil idea.status
    assert_not idea.open?
    assert_equal "Planned", idea.status_name
    assert_equal statuses(:planned).color, idea.status_color
  end

  test "no official response by default" do
    assert_nil @idea.official_comment
    assert_not @idea.official_response?
  end

  test "official_response? returns true when official_comment is set" do
    @idea.update!(official_comment: comments(:one))

    assert_predicate @idea, :official_response?
  end

  test "official comment must belong to the same idea" do
    other_idea_comment = comments(:two)
    other_idea_comment.update_columns(idea_id: ideas(:two).id)

    @idea.official_comment = other_idea_comment

    assert_not @idea.valid?
    assert_equal "must belong to this idea", @idea.errors[:official_comment].first
  end

  test "official comment on same idea is valid" do
    @idea.official_comment = comments(:one)

    assert_predicate @idea, :valid?
  end

  test "set_official_response! sets comment for admin" do
    @idea.set_official_response!(comments(:one), actor: users(:shane))

    assert_equal comments(:one), @idea.official_comment
  end

  test "set_official_response! raises for non-admin" do
    assert_raises(ArgumentError) do
      @idea.set_official_response!(comments(:one), actor: users(:jane))
    end
  end

  test "set_official_response! replaces previous official comment" do
    @idea.update!(official_comment: comments(:one))

    @idea.set_official_response!(comments(:two), actor: users(:shane))

    assert_equal comments(:two), @idea.reload.official_comment
  end

  test "clear_official_response! clears comment for admin" do
    @idea.update!(official_comment: comments(:one))

    @idea.clear_official_response!(actor: users(:shane))

    assert_nil @idea.reload.official_comment
  end

  test "clear_official_response! raises for non-admin" do
    @idea.update!(official_comment: comments(:one))

    assert_raises(ArgumentError) do
      @idea.clear_official_response!(actor: users(:jane))
    end
  end

  test "comments_locked defaults to false" do
    idea = Idea.create!(
      title: "Test",
      creator: users(:shane),
      board: boards(:one)
    )

    assert_not idea.comments_locked?
  end

  test "can lock and unlock comments" do
    idea = ideas(:one)

    assert_not idea.comments_locked?

    idea.update!(comments_locked: true)

    assert_predicate idea, :comments_locked?

    idea.update!(comments_locked: false)

    assert_not idea.comments_locked?
  end
end
