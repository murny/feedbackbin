# frozen_string_literal: true

require "test_helper"

module Users
  class AvatarsHelperTest < ActionView::TestCase
    setup do
      @user = users(:shane)
    end

    test "avatar_background_color" do
      assert_equal "#698F9C", avatar_background_color(@user)
    end

    test "avatar_tag" do
      tag = avatar_tag(@user)
      account_slug = Current.account.slug

      assert_match %r{<a title="#{CGI.escapeHTML(@user.name)}" data-turbo-frame="_top" href="#{account_slug}/users/#{@user.to_param}">}, tag
      assert_match %r{<img alt="#{@user.name}" loading="lazy" src="#{account_slug}/users/#{@user.to_param}/avatar\?v=\d+" /></a>}, tag
    end
  end
end
