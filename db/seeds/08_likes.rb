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

# FeedbackBin likes
ApplicationRecord.with_tenant(feedbackbin_org.subdomain) do
  # Find posts by title within this tenant
  dark_mode = Post.find_by!(title: "Could you please add dark mode")
  mobile = Post.find_by!(title: "Mobile app support")
  accessibility = Post.find_by!(title: "Accessibility improvements needed")
  api = Post.find_by!(title: "Public API for integrations")

  Like.find_or_create_by!(
    likeable: dark_mode,
    voter: maya_user
  )

  Like.find_or_create_by!(
    likeable: dark_mode,
    voter: alex_user
  )

  Like.find_or_create_by!(
    likeable: dark_mode,
    voter: carlos_user
  )

  Like.find_or_create_by!(
    likeable: mobile,
    voter: carlos_user
  )

  Like.find_or_create_by!(
    likeable: mobile,
    voter: david_user
  )

  Like.find_or_create_by!(
    likeable: accessibility,
    voter: sarah_user
  )

  Like.find_or_create_by!(
    likeable: accessibility,
    voter: maya_user
  )

  Like.find_or_create_by!(
    likeable: api,
    voter: alex_user
  )

  Like.find_or_create_by!(
    likeable: api,
    voter: maya_user
  )

  Like.find_or_create_by!(
    likeable: api,
    voter: sarah_user
  )
end

# TechCorp likes
ApplicationRecord.with_tenant(techcorp_org.subdomain) do
  dashboard = Post.find_by!(title: "Dashboard performance improvements")

  Like.find_or_create_by!(
    likeable: dashboard,
    voter: maya_user
  )

  Like.find_or_create_by!(
    likeable: dashboard,
    voter: carlos_user
  )
end

# InnovateLabs likes
ApplicationRecord.with_tenant(innovatelabs_org.subdomain) do
  figma_integration = Post.find_by!(title: "Figma integration for design handoffs")
  realtime_collab = Post.find_by!(title: "Real-time collaboration features")

  Like.find_or_create_by!(
    likeable: figma_integration,
    voter: david_user
  )

  Like.find_or_create_by!(
    likeable: figma_integration,
    voter: maya_user
  )

  Like.find_or_create_by!(
    likeable: realtime_collab,
    voter: admin_user
  )
end

puts "✅ Seeded likes"
