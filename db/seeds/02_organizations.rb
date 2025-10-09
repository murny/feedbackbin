# frozen_string_literal: true

puts "Creating organizations..."

Organization.find_or_create_by!(name: "FeedbackBin") do |org|
  org.subdomain = "feedbackbin"
  org.default_post_status = PostStatus.ordered.first
end

puts "✅ Seeded organizations"
