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

if Rails.env.development?
  puts "🌱 Seeding development data..."

  Dir[Rails.root.join('db', 'seeds', '*.rb')].sort.each do |file|
    puts "Loading #{File.basename(file)}..."
    load file
  end

  puts "✅ Seeding complete!"
end
