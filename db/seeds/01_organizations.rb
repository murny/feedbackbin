# frozen_string_literal: true

puts "Creating organizations in shared database..."

# Create organizations in the shared database
# These will be created before switching to tenant databases

Organization.find_or_create_by!(name: "FeedbackBin") do |org|
  org.subdomain = "feedbackbin"
end

Organization.find_or_create_by!(name: "Hooli") do |org|
  org.subdomain = "hooli"
end

Organization.find_or_create_by!(name: "Initech") do |org|
  org.subdomain = "initech"
end

puts "✅ Seeded organizations in shared database"