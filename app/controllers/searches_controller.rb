# frozen_string_literal: true

class SearchesController < ApplicationController
  allow_unauthenticated_access

  def show
    @query = Search::Query.wrap(params[:q])

    @results = if @query.present?
      Current.user ? Current.user.search(@query) : Search::Record.search(@query, account: Current.account)
    else
      []
    end

    @recent_visits = if Current.user
      Current.user.visits.recent.where(account: Current.account).limit(5).includes(:idea)
    else
      Visit.none
    end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
