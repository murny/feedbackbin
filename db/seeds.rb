# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Prevent seed data from running in production
if Rails.env.production?
  puts "⚠️ Skipping seed data in production environment"
  return
end

puts "🌱 Seeding development data..."

# First, load organization data in shared database
puts "Loading organizations into shared database..."
load Rails.root.join('db', 'seeds', '01_organizations.rb')

# Then load tenant-specific data for each organization
organizations = %w[feedbackbin hooli initech]

organizations.each do |org_subdomain|
  puts "\n🏢 Seeding data for #{org_subdomain} tenant..."

  # Load all seed files for this organization in order
  Dir[Rails.root.join('db', 'seeds', 'organizations', org_subdomain, '*.rb')].sort.each do |file|
    puts "  Loading #{File.basename(file)} for #{org_subdomain}..."
    load file
  end
end

puts "\n✅ Seeding complete!"
