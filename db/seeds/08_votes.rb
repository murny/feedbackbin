# frozen_string_literal: true

puts "Creating votes..."

# Find users by email address
admin_user = User.find_by!(email_address: "shane.murnaghan@feedbackbin.com")
maya_user = User.find_by!(email_address: "maya.patel@designstudio.co")
alex_user = User.find_by!(email_address: "alex.chen@techcorp.com")
carlos_user = User.find_by!(email_address: "carlos.rodriguez@freelance.dev")
david_user = User.find_by!(email_address: "david.thompson@agency.com")
sarah_user = User.find_by!(email_address: "sarah.kim@startup.io")

# Find ideas by title
dark_mode = Idea.find_by!(title: "Could you please add dark mode")
mobile = Idea.find_by!(title: "Mobile app support")
accessibility = Idea.find_by!(title: "Accessibility improvements needed")
api = Idea.find_by!(title: "Public API for integrations")

# Votes on FeedbackBin ideas
Vote.find_or_create_by!(
  voteable: dark_mode,
  voter: maya_user,
)

Vote.find_or_create_by!(
  voteable: dark_mode,
  voter: alex_user,
)

Vote.find_or_create_by!(
  voteable: dark_mode,
  voter: carlos_user,
)

Vote.find_or_create_by!(
  voteable: mobile,
  voter: carlos_user,
)

Vote.find_or_create_by!(
  voteable: mobile,
  voter: david_user,
)

Vote.find_or_create_by!(
  voteable: accessibility,
  voter: sarah_user,
)

Vote.find_or_create_by!(
  voteable: accessibility,
  voter: maya_user,
)

Vote.find_or_create_by!(
  voteable: api,
  voter: alex_user,
)

Vote.find_or_create_by!(
  voteable: api,
  voter: maya_user,
)

Vote.find_or_create_by!(
  voteable: api,
  voter: sarah_user,
)

puts "✅ Seeded votes"
