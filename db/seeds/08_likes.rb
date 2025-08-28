# frozen_string_literal: true

puts "Creating likes..."

# Find organizations by name
feedbackbin_org = Organization.find_by!(name: "FeedbackBin")
techcorp_org = Organization.find_by!(name: "TechCorp")
innovatelabs_org = Organization.find_by!(name: "InnovateLabs")

# Find users by email address
admin_user = User.find_by!(email_address: "shane.murnaghan@feedbackbin.com")
maya_user = User.find_by!(email_address: "maya.patel@designstudio.co")
alex_user = User.find_by!(email_address: "alex.chen@techcorp.com")
carlos_user = User.find_by!(email_address: "carlos.rodriguez@freelance.dev")
david_user = User.find_by!(email_address: "david.thompson@agency.com")
sarah_user = User.find_by!(email_address: "sarah.kim@startup.io")

# Find posts by title and organization
dark_mode = Post.find_by!(title: "Could you please add dark mode", organization: feedbackbin_org)
mobile = Post.find_by!(title: "Mobile app support", organization: feedbackbin_org)
accessibility = Post.find_by!(title: "Accessibility improvements needed", organization: feedbackbin_org)
api = Post.find_by!(title: "Public API for integrations", organization: feedbackbin_org)
dashboard = Post.find_by!(title: "Dashboard performance improvements", organization: techcorp_org)
figma_integration = Post.find_by!(title: "Figma integration for design handoffs", organization: innovatelabs_org)
realtime_collab = Post.find_by!(title: "Real-time collaboration features", organization: innovatelabs_org)

# Likes on FeedbackBin posts
Like.find_or_create_by!(
  likeable: dark_mode,
  voter: maya_user,
  organization: feedbackbin_org
)

Like.find_or_create_by!(
  likeable: dark_mode,
  voter: alex_user,
  organization: feedbackbin_org
)

Like.find_or_create_by!(
  likeable: dark_mode,
  voter: carlos_user,
  organization: feedbackbin_org
)

Like.find_or_create_by!(
  likeable: mobile,
  voter: carlos_user,
  organization: feedbackbin_org
)

Like.find_or_create_by!(
  likeable: mobile,
  voter: david_user,
  organization: feedbackbin_org
)

Like.find_or_create_by!(
  likeable: accessibility,
  voter: sarah_user,
  organization: feedbackbin_org
)

Like.find_or_create_by!(
  likeable: accessibility,
  voter: maya_user,
  organization: feedbackbin_org
)

Like.find_or_create_by!(
  likeable: api,
  voter: alex_user,
  organization: feedbackbin_org
)

Like.find_or_create_by!(
  likeable: api,
  voter: maya_user,
  organization: feedbackbin_org
)

Like.find_or_create_by!(
  likeable: api,
  voter: sarah_user,
  organization: feedbackbin_org
)

# Likes on TechCorp posts
Like.find_or_create_by!(
  likeable: dashboard,
  voter: maya_user,
  organization: techcorp_org
)

Like.find_or_create_by!(
  likeable: dashboard,
  voter: carlos_user,
  organization: techcorp_org
)

# Likes on InnovateLabs posts
Like.find_or_create_by!(
  likeable: figma_integration,
  voter: david_user,
  organization: innovatelabs_org
)

Like.find_or_create_by!(
  likeable: figma_integration,
  voter: maya_user,
  organization: innovatelabs_org
)

Like.find_or_create_by!(
  likeable: realtime_collab,
  voter: admin_user,
  organization: innovatelabs_org
)

total_likes = Like.count
puts "✅ Created #{total_likes} likes across all organizations"
