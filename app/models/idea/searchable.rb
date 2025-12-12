# frozen_string_literal: true

class Idea
  module Searchable
    extend ActiveSupport::Concern

    class_methods do
      def search(query)
        return all if query.blank?

        left_joins(:rich_text_body)
        .where(
          arel_table[:title].matches("%#{sanitize_sql_like(query.to_s)}%")
          .or(ActionText::RichText.arel_table[:body].matches("%#{sanitize_sql_like(query.to_s)}%"))
        )
      end
    end
  end
end
