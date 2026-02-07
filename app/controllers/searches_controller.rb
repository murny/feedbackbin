# frozen_string_literal: true

class SearchesController < ApplicationController
  allow_unauthenticated_access

  def show
    @query = Search::Query.sanitize(params[:q])

    if @query.present?
      records = Search::Record.search(@query, account: Current.account)
      @results = Search::Highlighter.build_results(records, @query)
    else
      @results = []
    end

    @recent_queries = Current.user ? Search::Query.where(account: Current.account, user: Current.user).recent : []

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
