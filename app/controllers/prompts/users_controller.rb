# frozen_string_literal: true

module Prompts
  class UsersController < ApplicationController
    skip_after_action :verify_authorized

    def index
      @users = User.active.alphabetically

      if stale?(etag: @users)
        render layout: false
      end
    end
  end
end
