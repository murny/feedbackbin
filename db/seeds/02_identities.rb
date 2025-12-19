# frozen_string_literal: true

puts "Creating identities..."

Identity.find_or_create_by!(email_address: "shane.murnaghan@feedbackbin.com") do |identity|
  identity.email_address = "shane.murnaghan@feedbackbin.com"
  identity.password = "password123"
  identity.staff = true
end

Identity.find_or_create_by!(email_address: "fake_user@example.com") do |identity|
  identity.email_address = "fake_user@example.com"
  identity.password = "password123"
end

Identity.find_or_create_by!(email_address: "jane_doe@example.com") do |identity|
  identity.email_address = "jane_doe@example.com"
  identity.password = "password123"
end

# Additional creative users with detailed profiles
Identity.find_or_create_by!(email_address: "alex.chen@techcorp.com") do |identity|
  identity.email_address = "alex.chen@techcorp.com"
  identity.password = "password123"
end

Identity.find_or_create_by!(email_address: "maya.patel@designstudio.co") do |identity|
  identity.email_address = "maya.patel@designstudio.co"
  identity.password = "password123"
end

Identity.find_or_create_by!(email_address: "carlos.rodriguez@freelance.dev") do |identity|
  identity.email_address = "carlos.rodriguez@freelance.dev"
  identity.password = "password123"
end

Identity.find_or_create_by!(email_address: "sarah.kim@startup.io") do |identity|
  identity.email_address = "sarah.kim@startup.io"
  identity.password = "password123"
end

Identity.find_or_create_by!(email_address: "david.thompson@agency.com") do |identity|
  identity.email_address = "david.thompson@agency.com"
  identity.password = "password123"
end

puts "✅ Seeded identities"
