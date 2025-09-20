# frozen_string_literal: true

puts "Creating likes..."

# Find users by email address
admin_user = User.find_by!(email_address: "shane.murnaghan@feedbackbin.com")
maya_user = User.find_by!(email_address: "maya.patel@designstudio.co")
alex_user = User.find_by!(email_address: "alex.chen@techcorp.com")
carlos_user = User.find_by!(email_address: "carlos.rodriguez@freelance.dev")
david_user = User.find_by!(email_address: "david.thompson@agency.com")
sarah_user = User.find_by!(email_address: "sarah.kim@startup.io")

# Find posts by title and organization
dark_mode = Post.find_by!(title: "Could you please add dark mode")
mobile = Post.find_by!(title: "Mobile app support")
accessibility = Post.find_by!(title: "Accessibility improvements needed")
api = Post.find_by!(title: "Public API for integrations")

# Likes on FeedbackBin posts
Like.find_or_create_by!(
  likeable: dark_mode,
  voter: maya_user,
)

Like.find_or_create_by!(
  likeable: dark_mode,
  voter: alex_user,
)

Like.find_or_create_by!(
  likeable: dark_mode,
  voter: carlos_user,
)

Like.find_or_create_by!(
  likeable: mobile,
  voter: carlos_user,
)

Like.find_or_create_by!(
  likeable: mobile,
  voter: david_user,
)

Like.find_or_create_by!(
  likeable: accessibility,
  voter: sarah_user,
)

Like.find_or_create_by!(
  likeable: accessibility,
  voter: maya_user,
)

Like.find_or_create_by!(
  likeable: api,
  voter: alex_user,
)

Like.find_or_create_by!(
  likeable: api,
  voter: maya_user,
)

Like.find_or_create_by!(
  likeable: api,
  voter: sarah_user,
)

puts "✅ Seeded likes"
