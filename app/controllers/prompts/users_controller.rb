# frozen_string_literal: true

class Prompts::UsersController < ApplicationController
  skip_after_action :verify_authorized

  def index
    @users = Current.account.users.active.ordered

    if stale? etag: @users
      render layout: false
    end
  end
end
