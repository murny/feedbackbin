# frozen_string_literal: true

puts "Creating boards..."

# FeedbackBin boards
Board.find_or_create_by!(name: "Customer Feedback") do |board|
  board.description = "Share your ideas and help us improve our product"
  board.color = "#3b82f6"  # Blue
end

Board.find_or_create_by!(name: "Bug Reports") do |board|
  board.description = "Report issues and bugs you've encountered"
  board.color = "#ef4444"  # Red
end

Board.find_or_create_by!(name: "Feature Requests") do |board|
  board.description = "Suggest new features and improvements"
  board.color = "#10b981"  # Green
end

Board.find_or_create_by!(name: "UI/UX Feedback") do |board|
  board.description = "Share feedback about the user interface and experience"
  board.color = "#f59e0b"  # Orange
end

puts "✅ Seeded boards"
