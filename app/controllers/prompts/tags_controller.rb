# frozen_string_literal: true

class Prompts::TagsController < ApplicationController
  def index
    @tags = Current.account.tags.ordered

    if stale? etag: @tags
      render layout: false
    end
  end
end
