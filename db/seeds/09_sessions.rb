# frozen_string_literal: true

puts "Creating user sessions..."

# Create some active sessions for the admin user for testing
3.times do |i|
  Session.find_or_create_by!(user: $seed_users[:admin]) do |session|
    session.ip_address = "127.0.0.#{i + 1}"
    session.user_agent = "Mozilla/5.0 (Test Browser #{i + 1})"
    session.created_at = (i + 1).hours.ago
    session.updated_at = 30.minutes.ago
  end
end

total_sessions = Session.count
puts "✅ Created #{total_sessions} sessions for admin user"