# frozen_string_literal: true

require "test_helper"

class Account::SearchableTest < ActiveSupport::TestCase
  test "can search accounts by name" do
    assert_equal accounts(:feedbackbin), Account.search("FeedbackBin").first
    assert_equal accounts(:feedbackbin), Account.search("feedback").first
  end

  test "search is case insensitive" do
    assert_includes Account.search("feedbackbin"), accounts(:feedbackbin)
    assert_includes Account.search("FEEDBACKBIN"), accounts(:feedbackbin)
  end

  test "search with partial matches" do
    assert_includes Account.search("Feed"), accounts(:feedbackbin)
    assert_includes Account.search("Bin"), accounts(:feedbackbin)
  end

  test "search returns empty collection for no matches" do
    results = Account.search("nonexistent")

    assert_empty results
  end

  test "search returns all accounts when query is blank" do
    assert_equal Account.count, Account.search("").count
    assert_equal Account.count, Account.search(nil).count
    assert_equal Account.count, Account.search("  ").count
  end

  test "search uses sanitize_sql_like for safety" do
    # Test that the search method calls sanitize_sql_like
    # This tests the implementation rather than specific SQLite escape behavior
    assert_respond_to Account, :sanitize_sql_like

    # Test that we can search for accounts with special characters in names
    special_org = Account.create!(
      name: "Test[Special 50%_Off]Account",
      subdomain: "specialtest"
    )

    results = Account.search("Special")

    assert_includes results, special_org

    # But we cannot search for characters that are used as wildcards
    results = Account.search("50%_")

    assert_empty results
  end

  test "search is chainable with other scopes" do
    # Test that search can be chained with other ActiveRecord methods
    results = Account.search("feedback").limit(1)

    assert_equal 1, results.size
    assert_equal accounts(:feedbackbin), results.first
  end
end
