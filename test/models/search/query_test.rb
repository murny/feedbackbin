# frozen_string_literal: true

require "test_helper"

class Search::QueryTest < ActiveSupport::TestCase
  test "wrap returns existing Search::Query unchanged" do
    query = Search::Query.new("dark")

    assert_same query, Search::Query.wrap(query)
  end

  test "wrap builds a Search::Query from a string" do
    query = Search::Query.wrap("dark mode")

    assert_kind_of Search::Query, query
    assert_equal "dark mode", query.to_s
  end

  test "valid? false for blank input" do
    assert_not Search::Query.new(nil).valid?
    assert_not Search::Query.new("").valid?
    assert_not Search::Query.new("   ").valid?
  end

  test "valid? true for word input" do
    assert_predicate Search::Query.new("dark"), :valid?
  end

  test "valid? false for pure-punctuation input" do
    assert_not Search::Query.new("???").valid?
    assert_not Search::Query.new("!!!").valid?
  end

  test "sanitizes invalid characters" do
    assert_equal "dark mode", Search::Query.new("dark$@! mode").to_s
  end

  test "drops unbalanced quotes" do
    assert_equal "dark mode", Search::Query.new('"dark mode').to_s
    assert_equal '"dark mode"', Search::Query.new('"dark mode"').to_s
  end

  test "strips bare operators" do
    assert_equal "dark mode", Search::Query.new("- * dark mode").to_s
  end

  test "preserves prefix wildcards" do
    assert_equal "dark*", Search::Query.new("dark*").to_s
  end

  test "blank? mirrors valid?" do
    assert_predicate Search::Query.new(""), :blank?
    assert_not Search::Query.new("dark").blank?
  end
end
