# frozen_string_literal: true

namespace :search do
  desc "Clear and rebuild the search index from all Ideas and Comments"
  task reindex: :environment do
    print "Clearing search index..."
    Search::Record.destroy_all
    puts " done."

    print "Indexing ideas..."
    count = 0
    Idea.includes(:rich_text_description).find_each do |idea|
      idea.reindex
      count += 1
    end
    puts " #{count} ideas indexed."

    print "Indexing comments..."
    count = 0
    Comment.includes(:rich_text_body, idea: :board).find_each do |comment|
      comment.reindex
      count += 1
    end
    puts " #{count} comments indexed."
  end
end
