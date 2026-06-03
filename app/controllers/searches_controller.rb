# frozen_string_literal: true

class SearchesController < ApplicationController
  allow_unauthenticated_access

  def show
    @query = Search::Record.sanitize_query(params[:q])

    if @query.present?
      records = Search::Record.search(@query, account: Current.account)
      @results = Search::Highlighter.build_results(records, @query)
    else
      @results = []
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
