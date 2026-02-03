# frozen_string_literal: true

class TagsController < ApplicationController
  def index
    @tags = Current.account.tags.alphabetically
  end
end
