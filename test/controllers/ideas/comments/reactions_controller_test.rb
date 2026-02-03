# frozen_string_literal: true

require "test_helper"

class Ideas::Comments::ReactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:shane)
    @idea = ideas(:one)
    @comment = comments(:one)
  end

  test "should get index" do
    sign_in_as @user

    get idea_comment_reactions_url(@idea, @comment)

    assert_response :success
  end

  test "should get new" do
    sign_in_as @user

    get new_idea_comment_reaction_url(@idea, @comment)

    assert_response :success
  end

  test "should create reaction if authenticated" do
    sign_in_as @user

    assert_difference "Reaction.count" do
      post idea_comment_reactions_url(@idea, @comment),
           params: { reaction: { content: "👍" } },
           as: :turbo_stream
    end

    assert_response :success

    reaction = Reaction.last

    assert_equal "👍", reaction.content
    assert_equal @user, reaction.reacter
    assert_equal @comment, reaction.reactable
  end

  test "should not create reaction if not authenticated" do
    assert_no_difference "Reaction.count" do
      post idea_comment_reactions_url(@idea, @comment),
           params: { reaction: { content: "👍" } }
    end

    assert_response :redirect
    assert_redirected_to sign_in_url
  end

  test "should destroy reaction if owner" do
    sign_in_as @user

    reaction = Reaction.create!(
      reactable: @comment,
      reacter: @user,
      content: "👍"
    )

    assert_difference "Reaction.count", -1 do
      delete idea_comment_reaction_url(@idea, @comment, reaction),
             as: :turbo_stream
    end

    assert_response :success
  end

  test "should not destroy reaction if not owner" do
    other_user = users(:john)
    reaction = Reaction.create!(
      reactable: @comment,
      reacter: other_user,
      content: "👍"
    )

    sign_in_as @user

    assert_no_difference "Reaction.count" do
      delete idea_comment_reaction_url(@idea, @comment, reaction),
             as: :turbo_stream
    end

    assert_response :forbidden
  end

  test "should not destroy reaction if not authenticated" do
    reaction = Reaction.create!(
      reactable: @comment,
      reacter: @user,
      content: "👍"
    )

    assert_no_difference "Reaction.count" do
      delete idea_comment_reaction_url(@idea, @comment, reaction)
    end

    assert_response :redirect
    assert_redirected_to sign_in_url
  end

  test "should toggle reaction - remove if already exists" do
    sign_in_as @user

    Reaction.create!(
      reactable: @comment,
      reacter: @user,
      content: "👍"
    )

    assert_difference "Reaction.count", -1 do
      post idea_comment_reactions_url(@idea, @comment),
           params: { reaction: { content: "👍" } },
           as: :turbo_stream
    end

    assert_response :success
  end
end
