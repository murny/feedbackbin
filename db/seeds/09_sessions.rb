# frozen_string_literal: true

puts "Creating user sessions..."

# Find admin user by email
admin_user = User.find_by!(email_address: "shane.murnaghan@feedbackbin.com")

# Create some active sessions for the admin user for testing

# Mobile phone session
Session.find_or_create_by!(user: admin_user, ip_address: "192.168.1.100") do |session|
  session.user_agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
  session.created_at = 3.hours.ago
  session.updated_at = 30.minutes.ago
end

# Linux desktop session
Session.find_or_create_by!(user: admin_user, ip_address: "192.168.1.101") do |session|
  session.user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
  session.created_at = 2.hours.ago
  session.updated_at = 15.minutes.ago
end

# Windows desktop session
Session.find_or_create_by!(user: admin_user, ip_address: "192.168.1.102") do |session|
  session.user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
  session.created_at = 1.hour.ago
  session.updated_at = 5.minutes.ago
end

total_sessions = Session.count
puts "✅ Created #{total_sessions} sessions for admin user"
