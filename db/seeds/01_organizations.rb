# frozen_string_literal: true

puts "Creating organizations..."

Organization.find_or_create_by!(name: "FeedbackBin") do |org|
  org.subdomain = "feedbackbin"
end

puts "✅ Seeded organizations"
