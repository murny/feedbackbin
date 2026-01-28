# frozen_string_literal: true

class Prompts::UsersController < ApplicationController
  def index
    @users = Current.account.users.active.ordered

    if stale? etag: @users
      render layout: false
    end
  end
end
