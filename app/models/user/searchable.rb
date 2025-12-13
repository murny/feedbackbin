# frozen_string_literal: true

class User
  module Searchable
    extend ActiveSupport::Concern

    class_methods do
      def search(query)
        return all if query.blank?

        identities = Identity.arel_table
        users = arel_table
        q = "%#{sanitize_sql_like(query.to_s)}%"

        joins(:identity).where(
          users[:name].matches(q).or(identities[:email_address].matches(q))
        )
      end
    end
  end
end
