# frozen_string_literal: true

module ModelSortable
  extend ActiveSupport::Concern

  class_methods do
    # Orders results by column and direction
    def sort_by_params(column, direction)
      # TODO: We currently duplicating logic here and in sortable controller concern
      sortable_column = column.presence_in(sortable_columns) || "created_at"
      order(sortable_column => direction)
    end

    # Returns an array of sortable columns on the model
    # Used with the Sortable controller concern
    #
    # Override this method to add/remove sortable columns
    def sortable_columns
      @sortable_columns ||= columns.map(&:name)
    end
  end
end
