# frozen_string_literal: true

class PostTag < ApplicationRecord
  belongs_to :post
  belongs_to :tag, counter_cache: :posts_count

  validates :post_id, uniqueness: { scope: :tag_id }
end