# frozen_string_literal: true

class User
  module Searchable
    extend ActiveSupport::Concern

    class_methods do
      def search(query)
        return all if query.blank?

        sanitized_query = "%#{sanitize_sql_like(query.to_s)}%"

        left_joins(:identity).where(
          arel_table[:name].matches(sanitized_query)
          .or(Identity.arel_table[:email_address].matches(sanitized_query))
        )
      end
    end
  end
end
