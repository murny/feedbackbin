# frozen_string_literal: true

puts "Creating user sessions..."

# Find admin identity by email
account = Account.find_by!(name: "FeedbackBin")
identity = Identity.find_by!(email_address: "shane.murnaghan@feedbackbin.com")

# Create some active sessions for the admin user for testing

# Mobile phone session
Session.find_or_create_by!(identity: identity, current_account: account, ip_address: "192.168.1.100") do |session|
  session.user_agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
  session.last_active_at = 30.minutes.ago
end

# Linux desktop session
Session.find_or_create_by!(identity: identity, current_account: account, ip_address: "192.168.1.101") do |session|
  session.user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
  session.last_active_at = 15.minutes.ago
end

# Windows desktop session
Session.find_or_create_by!(identity: identity, current_account: account, ip_address: "192.168.1.102") do |session|
  session.user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
  session.last_active_at = 5.minutes.ago
end

puts "✅ Seeded sessions"
