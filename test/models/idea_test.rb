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

  test "ideas are scoped to their account via association" do
    feedbackbin_idea = ideas(:one)

    assert_includes accounts(:feedbackbin).ideas, feedbackbin_idea
    assert_not_includes accounts(:acme).ideas, feedbackbin_idea
  end

  test "acme account scope cannot find a feedbackbin idea" do
    feedbackbin_idea = ideas(:one)

    assert_raises(ActiveRecord::RecordNotFound) do
      accounts(:acme).ideas.find(feedbackbin_idea.id)
    end
  end

  test "acme account scope returns its own ideas" do
    assert_includes accounts(:acme).ideas, ideas(:acme_one)
  end

  test "similar_to returns none for blank query" do
    assert_empty Idea.similar_to("", account: accounts(:feedbackbin))
    assert_empty Idea.similar_to(nil, account: accounts(:feedbackbin))
  end

  test "similar_to returns none for query shorter than 3 chars" do
    assert_empty Idea.similar_to("ab", account: accounts(:feedbackbin))
  end

  test "similar_to returns matching ideas in bm25 order" do
    Search::Record.destroy_all
    Search::Record.upsert_for(ideas(:one))   # "Wish this had dark mode!"
    Search::Record.upsert_for(ideas(:two))   # "Love the site, can you implement downvotes?"
    Search::Record.upsert_for(ideas(:three)) # "Allow visitors to post without having to sign in"

    results = Idea.similar_to("dark", account: accounts(:feedbackbin))

    assert_includes results, ideas(:one)
    assert_equal ideas(:one), results.first
  end

  test "similar_to respects account scope" do
    Search::Record.destroy_all
    Search::Record.upsert_for(ideas(:one))      # feedbackbin: "Wish this had dark mode!"
    Search::Record.upsert_for(ideas(:acme_one)) # acme: "Acme-scoped idea for isolation testing"

    feedbackbin_results = Idea.similar_to("Acme", account: accounts(:feedbackbin))

    assert_not_includes feedbackbin_results, ideas(:acme_one)
  end

  test "similar_to returns at most `limit` results" do
    Search::Record.destroy_all
    Search::Record.upsert_for(ideas(:one))
    Search::Record.upsert_for(ideas(:two))
    Search::Record.upsert_for(ideas(:three))

    results = Idea.similar_to("the", account: accounts(:feedbackbin), limit: 1)

    assert_equal 1, results.size
  end

  test "similar_to preserves bm25 ranking when multiple ideas match" do
    Search::Record.destroy_all

    body_only = Idea.create!(
      title: "Voting feature suggestion",
      description: "Please add downvotes so unpopular ideas can sink.",
      creator: users(:shane),
      board: boards(:one)
    )
    Search::Record.upsert_for(ideas(:two)) # title contains "downvotes"
    Search::Record.upsert_for(body_only)   # only description contains "downvotes"

    results = Idea.similar_to("downvotes", account: accounts(:feedbackbin))

    assert_equal 2, results.size
    assert_equal ideas(:two), results.first
    assert_equal body_only, results.last
  end

  test "similar_to excludes the named idea id" do
    Search::Record.destroy_all

    body_only = Idea.create!(
      title: "Voting feature suggestion",
      description: "Please add downvotes so unpopular ideas can sink.",
      creator: users(:shane),
      board: boards(:one)
    )
    Search::Record.upsert_for(ideas(:two)) # title contains "downvotes"
    Search::Record.upsert_for(body_only)   # description contains "downvotes"

    results = Idea.similar_to("downvotes", account: accounts(:feedbackbin), exclude: ideas(:two).id)

    assert_not_includes results, ideas(:two)
    assert_includes results, body_only
  end

  test "similar_to with exclude: nil returns same results as omitting exclude" do
    Search::Record.destroy_all
    Search::Record.upsert_for(ideas(:one))

    with_nil = Idea.similar_to("dark", account: accounts(:feedbackbin), exclude: nil)
    without_kwarg = Idea.similar_to("dark", account: accounts(:feedbackbin))

    assert_equal without_kwarg, with_nil
  end
end
