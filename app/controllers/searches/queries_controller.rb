# frozen_string_literal: true

class Searches::QueriesController < ApplicationController
  def create
    Search::Query.track(params[:terms], user: Current.user)
    head :ok
  end
end
