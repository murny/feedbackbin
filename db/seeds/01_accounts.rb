# frozen_string_literal: true

puts "Creating accounts..."

Account.find_or_create_by!(name: "FeedbackBin") do |account|
  account.subdomain = "feedbackbin"
end

puts "✅ Seeded accounts"
