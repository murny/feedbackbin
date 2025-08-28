# frozen_string_literal: true

class User
  module Searchable
    extend ActiveSupport::Concern

    class_methods do
      def search(query)
        return all if query.blank?

        where(
          arel_table[:name].matches("%#{sanitize_sql_like(query.to_s)}%")
          .or(arel_table[:email_address].matches("%#{sanitize_sql_like(query.to_s)}%"))
          .or(arel_table[:username].matches("%#{sanitize_sql_like(query.to_s)}%"))
        )
      end
    end
  end
end