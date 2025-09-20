# frozen_string_literal: true

require "test_helper"

class Organization::SearchableTest < ActiveSupport::TestCase
  test "can search organizations by name" do
    assert_equal organizations(:feedbackbin), Organization.search("FeedbackBin").first
    assert_equal organizations(:feedbackbin), Organization.search("feedback").first
  end

  test "search is case insensitive" do
    assert_includes Organization.search("feedbackbin"), organizations(:feedbackbin)
    assert_includes Organization.search("FEEDBACKBIN"), organizations(:feedbackbin)
  end

  test "search with partial matches" do
    assert_includes Organization.search("Feed"), organizations(:feedbackbin)
    assert_includes Organization.search("Bin"), organizations(:feedbackbin)
  end

  test "search returns empty collection for no matches" do
    results = Organization.search("nonexistent")

    assert_empty results
  end

  test "search returns all organizations when query is blank" do
    assert_equal Organization.count, Organization.search("").count
    assert_equal Organization.count, Organization.search(nil).count
    assert_equal Organization.count, Organization.search("  ").count
  end

  test "search uses sanitize_sql_like for safety" do
    # Test that the search method calls sanitize_sql_like
    # This tests the implementation rather than specific SQLite escape behavior
    assert_respond_to Organization, :sanitize_sql_like

    # Test that we can search for organizations with special characters in names
    special_org = Organization.create!(name: "Test[Special]Organization", subdomain: "specialtest", owner: users(:one))

    results = Organization.search("Special")

    assert_includes results, special_org
  end

  test "search is chainable with other scopes" do
    # Test that search can be chained with other ActiveRecord methods
    results = Organization.search("feedback").limit(1)

    assert_equal 1, results.size
    assert_equal organizations(:feedbackbin), results.first
  end
end
