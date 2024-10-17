# frozen_string_literal: true

require "test_helper"

class Users::AvatarsHelperTest < ActionView::TestCase
  setup do
    @user = users(:one)
  end

  test "avatar_background_color" do
    assert_equal "#67695E", avatar_background_color(@user)
  end

  test "avatar_tag" do
    tag = avatar_tag(@user)

    assert_match %r{<a title="#{CGI.escapeHTML(@user.title)}" data-turbo-frame="_top" href="/users/#{@user.id}">}, tag
    assert_match %r{<img role="presentation" src="/users/#{@user.id}/avatar\?v=\d+" /></a>}, tag
  end
end
