# frozen_string_literal: true

module UserSettings
  class AccountsController < ApplicationController
    skip_after_action :verify_authorized

    def show
      @user = Current.user
      @identity = Current.identity
      # TODO: Need to make this a hash with id and provider_name to simplify the view code and prevent repeated calls to the database
      @identity_connected_accounts = Current.identity.identity_connected_accounts.order(provider_name: :asc, created_at: :desc)
    end
  end
end
