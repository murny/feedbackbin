# frozen_string_literal: true

class Post
  module Searchable
    extend ActiveSupport::Concern

    class_methods do
      def search(query)
        return all if query.blank?

        joins(:author)
        .where(
          arel_table[:title].matches("%#{sanitize_sql_like(query.to_s)}%")
          .or(arel_table[:body].matches("%#{sanitize_sql_like(query.to_s)}%"))
          .or(User.arel_table[:name].matches("%#{sanitize_sql_like(query.to_s)}%"))
        )
      end
    end
  end
end