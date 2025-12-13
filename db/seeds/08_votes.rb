# frozen_string_literal: true

puts "Creating votes..."

# Account context
account = Account.find_by!(name: "FeedbackBin")
Current.account = account

# Find users (memberships) by identity email
admin_user = Identity.find_by!(email_address: "shane.murnaghan@feedbackbin.com").user_for(account)
maya_user = Identity.find_by!(email_address: "maya.patel@designstudio.co").user_for(account)
alex_user = Identity.find_by!(email_address: "alex.chen@techcorp.com").user_for(account)
carlos_user = Identity.find_by!(email_address: "carlos.rodriguez@freelance.dev").user_for(account)
david_user = Identity.find_by!(email_address: "david.thompson@agency.com").user_for(account)
sarah_user = Identity.find_by!(email_address: "sarah.kim@startup.io").user_for(account)

# Find ideas by title
dark_mode = Idea.find_by!(account: account, title: "Could you please add dark mode")
mobile = Idea.find_by!(account: account, title: "Mobile app support")
accessibility = Idea.find_by!(account: account, title: "Accessibility improvements needed")
api = Idea.find_by!(account: account, title: "Public API for integrations")

# Votes on FeedbackBin ideas
Vote.find_or_create_by!(
  account: account,
  voteable: dark_mode,
  voter: maya_user,
)

Vote.find_or_create_by!(
  account: account,
  voteable: dark_mode,
  voter: alex_user,
)

Vote.find_or_create_by!(
  account: account,
  voteable: dark_mode,
  voter: carlos_user,
)

Vote.find_or_create_by!(
  account: account,
  voteable: mobile,
  voter: carlos_user,
)

Vote.find_or_create_by!(
  account: account,
  voteable: mobile,
  voter: david_user,
)

Vote.find_or_create_by!(
  account: account,
  voteable: accessibility,
  voter: sarah_user,
)

Vote.find_or_create_by!(
  account: account,
  voteable: accessibility,
  voter: maya_user,
)

Vote.find_or_create_by!(
  account: account,
  voteable: api,
  voter: alex_user,
)

Vote.find_or_create_by!(
  account: account,
  voteable: api,
  voter: maya_user,
)

Vote.find_or_create_by!(
  account: account,
  voteable: api,
  voter: sarah_user,
)

puts "✅ Seeded votes"
