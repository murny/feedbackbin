# frozen_string_literal: true

module Sortable
  extend ActiveSupport::Concern

  included do
    helper_method :sort_column, :sort_direction
  end

  def sort_column(klass, default: "created_at")
    params[:sort].presence_in(klass.sortable_columns) || default
  end

  def sort_direction(default: "asc")
    params[:direction].presence_in(%w[asc desc]) || default
  end
end
