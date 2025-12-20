# frozen_string_literal: true

require "test_helper"

module Users
  class AvatarsHelperTest < ActionView::TestCase
    setup do
      @user = users(:jane)
      Current.account = @user.account
      # Set controller default_url_options for account scope
      @controller.class.default_url_options[:script_name] = @user.account.slug
    end

    teardown do
      Current.reset
      @controller.class.default_url_options.delete(:script_name)
    end

    test "avatar_background_color" do
      assert_equal "#ED3F1C", avatar_background_color(@user)
    end

    test "avatar_tag" do
      tag = avatar_tag(@user)
      account_slug = @user.account.slug

      assert_match %r{<a title="#{CGI.escapeHTML(@user.name)}" data-turbo-frame="_top" href="#{account_slug}/users/#{@user.to_param}">}, tag
      assert_match %r{<img alt="#{@user.name}" loading="lazy" src="#{account_slug}/users/#{@user.to_param}/avatar\?v=\d+" /></a>}, tag
    end
  end
end
