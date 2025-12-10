# frozen_string_literal: true

module UserSettings
  class AccountsController < ApplicationController
    skip_after_action :verify_authorized

    def show
      @user = Current.user
      # TODO: Need to make this a hash with id and provider_name to simplify the view code and prevent repeated calls to the database
      @user_connected_accounts = Current.user.user_connected_accounts.order(provider_name: :asc, created_at: :desc)
    end
  end
end
