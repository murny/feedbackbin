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
    votes.where(voter: voter).first_or_create
  end

  def unvote(voter)
    votes.where(voter: voter).destroy_all
  end
end
