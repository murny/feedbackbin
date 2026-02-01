# frozen_string_literal: true

require "test_helper"

class Prompts::IdeasControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:shane))
  end

  test "should get index" do
    get prompts_ideas_url

    assert_response :success
  end

  test "should return ideas as lexxy prompt items" do
    get prompts_ideas_url

    assert_select "lexxy-prompt-item", minimum: 1
  end

  test "should filter ideas by title" do
    idea = ideas(:one)
    get prompts_ideas_url, params: { filter: idea.title.first(5) }

    assert_response :success
    assert_select "lexxy-prompt-item"
  end

  test "should find ideas by id" do
    idea = ideas(:one)
    get prompts_ideas_url, params: { filter: idea.id.to_s }

    assert_response :success
  end
end
