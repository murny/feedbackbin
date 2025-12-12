# frozen_string_literal: true

puts "Creating accounts..."

Account.find_or_create_by!(name: "FeedbackBin") do |account|
  account.subdomain = "feedbackbin"
  account.default_status = Status.ordered.first
end

puts "✅ Seeded accounts"
