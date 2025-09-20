# frozen_string_literal: true

puts "Creating users for FeedbackBin tenant..."

# Set tenant context
ApplicationRecord.with_tenant("feedbackbin") do
  feedbackbin_org = Organization.find_by!(subdomain: "feedbackbin")

  User.find_or_create_by!(email_address: "shane.murnaghan@feedbackbin.com") do |user|
    user.name = "Shane Murnaghan"
    user.username = "Murny"
    user.password = "password123"
    user.super_admin = true
    user.email_verified = true
  end

  User.find_or_create_by!(email_address: "fake_user@example.com") do |user|
    user.name = "Fake User"
    user.username = "FakeUser"
    user.password = "password123"
    user.email_verified = true
  end

  User.find_or_create_by!(email_address: "jane_doe@example.com") do |user|
    user.name = "Jane Doe"
    user.username = "JaneDoe"
    user.password = "password123"
    user.email_verified = true
  end

  User.find_or_create_by!(email_address: "alex.chen@feedbackbin.com") do |user|
    user.name = "Alex Chen"
    user.username = "alexc"
    user.password = "password123"
    user.bio = "Product manager passionate about user experience. Coffee enthusiast and weekend rock climber."
    user.preferred_language = "en"
    user.time_zone = "America/Los_Angeles"
    user.email_verified = true
  end

  User.find_or_create_by!(email_address: "maya.patel@feedbackbin.com") do |user|
    user.name = "Maya Patel"
    user.username = "mayap"
    user.password = "password123"
    user.bio = "UX Designer with 8 years experience. Love creating intuitive interfaces that users actually enjoy."
    user.preferred_language = "en"
    user.time_zone = "America/New_York"
    user.email_verified = true
  end

  User.find_or_create_by!(email_address: "carlos.rodriguez@feedbackbin.com") do |user|
    user.name = "Carlos Rodriguez"
    user.username = "carlosr"
    user.password = "password123"
    user.bio = "Full-stack developer and digital nomad. Currently coding from Barcelona 🇪🇸"
    user.preferred_language = "es"
    user.time_zone = "Europe/Madrid"
    user.email_verified = true
  end

  User.find_or_create_by!(email_address: "david.thompson@feedbackbin.com") do |user|
    user.name = "David Thompson"
    user.username = "dthompson"
    user.password = "password123"
    user.bio = "Creative director with a knack for spotting design inconsistencies. Advocate for accessibility in digital products."
    user.preferred_language = "en"
    user.time_zone = "America/New_York"
    user.email_verified = true
  end

  # Set organization owner
  admin_user = User.find_by!(email_address: "shane.murnaghan@feedbackbin.com")
  feedbackbin_org.update!(owner: admin_user)
end

puts "✅ Seeded users for FeedbackBin tenant"