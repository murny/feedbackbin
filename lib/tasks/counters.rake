# frozen_string_literal: true

namespace :counters do
  desc "Recompute votes_count and comments_count from associated rows"
  task backfill: :environment do
    print "Backfilling idea counts..."
    count = 0
    Idea.find_each do |idea|
      idea.update_columns(
        comments_count: idea.comments.count,
        votes_count: idea.votes.count
      )
      count += 1
    end
    puts " #{count} ideas updated."

    print "Backfilling comment counts..."
    count = 0
    Comment.find_each do |comment|
      comment.update_columns(votes_count: comment.votes.count)
      count += 1
    end
    puts " #{count} comments updated."
  end
end
