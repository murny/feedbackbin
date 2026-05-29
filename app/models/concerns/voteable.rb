# frozen_string_literal: true

module Voteable
  extend ActiveSupport::Concern

  included do
    has_many :votes, as: :voteable, dependent: :destroy
    has_many :voters, through: :votes, source: :voter
  end

  def voted_by?(voter)
    votes.where(voter: voter).any?
  end

  def vote(voter)
    votes.where(voter: voter).first_or_create.tap do |vote|
      increment!(:votes_count) if vote.previously_new_record?
    end
  end

  def unvote(voter)
    votes.where(voter: voter).destroy_all.tap do |destroyed|
      decrement!(:votes_count, destroyed.size) if destroyed.any?
    end
  end

  # Returns the main content text for display (description for Ideas, body for Comments)
  def content_text
    respond_to?(:description) ? description : body
  end
end
