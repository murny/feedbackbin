# frozen_string_literal: true

puts "Creating user sessions..."

# Add realistic session data for Shane admin user
Session.find_or_create_by!(user: $seed_users[:admin], ip_address: "192.168.1.105") do |session|
  session.user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
  session.last_active_at = 2.hours.ago
  session.created_at = 1.week.ago
end

Session.find_or_create_by!(user: $seed_users[:admin], ip_address: "10.0.0.24") do |session|
  session.user_agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1 Mobile/15E148 Safari/604.1"
  session.last_active_at = 1.day.ago
  session.created_at = 3.days.ago
end

Session.find_or_create_by!(user: $seed_users[:admin], ip_address: "172.16.42.8") do |session|
  session.user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
  session.last_active_at = 30.minutes.ago
  session.created_at = 5.days.ago
end

puts "✅ Created #{Session.where(user: $seed_users[:admin]).count} sessions for admin user"
