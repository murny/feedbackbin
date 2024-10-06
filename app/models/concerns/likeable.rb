# frozen_string_literal: true

module Likeable
  extend ActiveSupport::Concern

  included do
    has_many :likes, as: :likeable, dependent: :destroy
  end

  def liked_by?(voter)
    likes.where(voter: voter).any?
  end

  def like(voter)
    likes.where(voter: voter).first_or_create
  end

  def unlike(voter)
    likes.where(voter: voter).destroy_all
  end
end
