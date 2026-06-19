# frozen_string_literal: true

require "test_helper"

class UnsubscribesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:jane)
    @idea = ideas(:one)
    @watch = watches(:jane_watching_one)
    @verifier = Rails.application.message_verifier(:watch_unsubscribe)
  end

  test "GET show with valid token renders the confirm landing without unsubscribing" do
    assert_predicate @watch, :watching?

    token = @verifier.generate(
      { watch_id: @watch.id, user_id: @user.id, idea_id: @idea.id },
      expires_in: 30.days
    )

    get unsubscribe_url(token: token)

    assert_response :success
    assert_match "Unsubscribe from updates", response.body
    assert_match unsubscribe_destroy_by_token_path(token: token), response.body
    assert_predicate @watch.reload, :watching?
  end

  test "GET show with invalid (tampered) token renders expired with 410 Gone" do
    get unsubscribe_url(token: "not-a-real-token")

    assert_response :gone
    assert_match "This unsubscribe link has expired", response.body
  end

  test "GET show with valid token but missing watch renders expired" do
    token = @verifier.generate(
      { watch_id: 999_999_999, user_id: @user.id, idea_id: @idea.id },
      expires_in: 30.days
    )

    get unsubscribe_url(token: token)

    assert_response :gone
    assert_match "This unsubscribe link has expired", response.body
  end

  test "GET show works without authenticated session" do
    sign_out

    token = @verifier.generate(
      { watch_id: @watch.id, user_id: @user.id, idea_id: @idea.id },
      expires_in: 30.days
    )

    get unsubscribe_url(token: token)

    assert_response :success
  end

  test "POST destroy_by_token with valid token toggles watch.watching to false" do
    assert_predicate @watch, :watching?

    token = @verifier.generate(
      { watch_id: @watch.id, user_id: @user.id, idea_id: @idea.id },
      expires_in: 30.days
    )

    post unsubscribe_destroy_by_token_url(token: token)

    assert_response :success
    assert_match "been unsubscribed", response.body
    assert_not @watch.reload.watching?
  end

  test "POST destroy_by_token with invalid (tampered) token renders expired with 410 Gone" do
    post unsubscribe_destroy_by_token_url(token: "not-a-real-token")

    assert_response :gone
    assert_match "This unsubscribe link has expired", response.body
  end

  test "POST destroy_by_token works without authenticated session" do
    sign_out

    token = @verifier.generate(
      { watch_id: @watch.id, user_id: @user.id, idea_id: @idea.id },
      expires_in: 30.days
    )

    post unsubscribe_destroy_by_token_url(token: token)

    assert_response :success
    assert_match "been unsubscribed", response.body
    assert_not @watch.reload.watching?
  end

  test "POST destroy_by_token with valid token but missing watch renders expired" do
    token = @verifier.generate(
      { watch_id: 999_999_999, user_id: @user.id, idea_id: @idea.id },
      expires_in: 30.days
    )

    post unsubscribe_destroy_by_token_url(token: token)

    assert_response :gone
    assert_match "This unsubscribe link has expired", response.body
  end

  test "POST destroy_by_token is a no-op when watch is already not watching" do
    @watch.update!(watching: false)

    token = @verifier.generate(
      { watch_id: @watch.id, user_id: @user.id, idea_id: @idea.id },
      expires_in: 30.days
    )

    assert_no_changes -> { @watch.reload.updated_at } do
      post unsubscribe_destroy_by_token_url(token: token)
    end

    assert_response :success
  end

  test "GET destroy_by_token is not routable" do
    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path("/unsubscribe/destroy_by_token", method: :get)
    end
  end
end
