# frozen_string_literal: true

require "test_helper"

class Search::QueryTest < ActiveSupport::TestCase
  setup do
    @user = users(:shane)
  end

  test "track creates a new query record" do
    assert_difference "Search::Query.count" do
      Search::Query.track("new search term", user: @user)
    end
  end

  test "track touches existing query on duplicate" do
    query = Search::Query.track("existing term", user: @user)
    original_updated_at = query.updated_at

    travel 1.minute do
      Search::Query.track("existing term", user: @user)
    end

    assert_operator query.reload.updated_at, :>, original_updated_at
  end

  test "track returns nil for blank terms" do
    result = Search::Query.track("", user: @user)

    assert_nil result
  end

  test "sanitize strips invalid characters" do
    assert_equal "hello world", Search::Query.sanitize("hello! @world#")
  end

  test "sanitize fixes unbalanced quotes" do
    assert_equal "hello world", Search::Query.sanitize('hello "world')
  end

  test "sanitize preserves balanced quotes" do
    assert_equal '"hello world"', Search::Query.sanitize('"hello world"')
  end

  test "sanitize squishes whitespace" do
    assert_equal "hello world", Search::Query.sanitize("  hello   world  ")
  end

  test "sanitize strips standalone asterisk" do
    assert_equal "", Search::Query.sanitize("*")
  end

  test "sanitize strips standalone dash" do
    assert_equal "", Search::Query.sanitize("-")
  end

  test "sanitize strips trailing bare asterisk" do
    assert_equal "hello", Search::Query.sanitize("hello *")
  end

  test "sanitize strips trailing bare dash" do
    assert_equal "hello", Search::Query.sanitize("hello -")
  end

  test "sanitize preserves prefix wildcard attached to word" do
    assert_equal "*test", Search::Query.sanitize("*test")
  end

  test "sanitize preserves suffix wildcard attached to word" do
    assert_equal "test*", Search::Query.sanitize("test*")
  end

  test "sanitize preserves prefix dash attached to word" do
    assert_equal "-test", Search::Query.sanitize("-test")
  end

  test "recent scope returns last 5 ordered by updated_at desc" do
    queries = Search::Query.where(user: @user, account: accounts(:feedbackbin)).recent

    assert_operator queries.size, :<=, 5
    assert_equal queries.sort_by { |q| -q.updated_at.to_i }, queries.to_a
  end
end
