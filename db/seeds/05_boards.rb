# frozen_string_literal: true

puts "Creating boards..."

# Boards are account-scoped
account = Account.find_by!(name: "FeedbackBin")
Current.account = account

# FeedbackBin boards
Board.find_or_create_by!(account: account, name: "Customer Feedback") do |board|
  board.description = "Share your ideas and help us improve our product"
  board.color = "#3b82f6"  # Blue
end

Board.find_or_create_by!(account: account, name: "Bug Reports") do |board|
  board.description = "Report issues and bugs you've encountered"
  board.color = "#ef4444"  # Red
end

Board.find_or_create_by!(account: account, name: "Feature Requests") do |board|
  board.description = "Suggest new features and improvements"
  board.color = "#10b981"  # Green
end

Board.find_or_create_by!(account: account, name: "UI/UX Feedback") do |board|
  board.description = "Share feedback about the user interface and experience"
  board.color = "#f59e0b"  # Orange
end

puts "✅ Seeded boards"
