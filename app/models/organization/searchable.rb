# frozen_string_literal: true

class Organization
  module Searchable
    extend ActiveSupport::Concern

    class_methods do
      def search(query)
        return all if query.blank?

        where(arel_table[:name].matches("%#{sanitize_sql_like(query.to_s)}%"))
      end
    end
  end
end
