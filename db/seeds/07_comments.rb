# frozen_string_literal: true

puts "Creating comments..."

# Find organizations by name
feedbackbin_org = Organization.find_by!(name: "FeedbackBin")
techcorp_org = Organization.find_by!(name: "TechCorp")
innovatelabs_org = Organization.find_by!(name: "InnovateLabs")

# Find users by email address
admin_user = User.find_by!(email_address: "shane.murnaghan@feedbackbin.com")
fake_user = User.find_by!(email_address: "fake_user@example.com")
jane_user = User.find_by!(email_address: "jane_doe@example.com")
alex_user = User.find_by!(email_address: "alex.chen@techcorp.com")
maya_user = User.find_by!(email_address: "maya.patel@designstudio.co")
carlos_user = User.find_by!(email_address: "carlos.rodriguez@freelance.dev")
sarah_user = User.find_by!(email_address: "sarah.kim@startup.io")
david_user = User.find_by!(email_address: "david.thompson@agency.com")

# Find posts by title and organization
dark_mode_post = Post.find_by!(title: "Could you please add dark mode", organization: feedbackbin_org)
mobile_app_post = Post.find_by!(title: "Mobile app support", organization: feedbackbin_org)
accessibility_post = Post.find_by!(title: "Accessibility improvements needed", organization: feedbackbin_org)
dashboard_post = Post.find_by!(title: "Dashboard performance improvements", organization: techcorp_org)
android_notifications_post = Post.find_by!(title: "Push notifications not working on Android", organization: innovatelabs_org)
figma_integration_post = Post.find_by!(title: "Figma integration for design handoffs", organization: innovatelabs_org)

# Disable comment broadcasting to make seeding faster
Comment.suppressing_turbo_broadcasts do
  # Comments on FeedbackBin dark mode post
  Comment.find_or_create_by!(
    post: dark_mode_post,
    creator: maya_user,
    organization: feedbackbin_org
  ) do |comment|
    comment.body = "This is a great suggestion! Dark mode would definitely improve the user experience, especially for those late-night feedback sessions."
    comment.created_at = 12.days.ago
  end

  Comment.find_or_create_by!(
    post: dark_mode_post,
    creator: alex_user,
    organization: feedbackbin_org
  ) do |comment|
    comment.body = "I second this! Most modern apps have dark mode now. It would also help with accessibility for users with light sensitivity."
    comment.created_at = 11.days.ago
  end

  # Comments on mobile app post
  Comment.find_or_create_by!(
    post: mobile_app_post,
    creator: carlos_user,
    organization: feedbackbin_org
  ) do |comment|
    comment.body = "A mobile app would be fantastic! I'm often reviewing feedback while commuting and the mobile web experience could be better."
    comment.created_at = 13.days.ago
  end

  # Comments on accessibility post
  Comment.find_or_create_by!(
    post: accessibility_post,
    creator: sarah_user,
    organization: feedbackbin_org
  ) do |comment|
    comment.body = "Thank you for bringing this up! Accessibility should be a priority. Would you be interested in helping us conduct a full accessibility audit?"
    comment.created_at = 6.days.ago
  end

  # Comments on TechCorp posts
  Comment.find_or_create_by!(
    post: dashboard_post,
    creator: maya_user,
    organization: techcorp_org
  ) do |comment|
    comment.body = "I've noticed the same issue. We should look into implementing lazy loading for the project cards."
    comment.created_at = 1.day.ago
  end

  # Comments on InnovateLabs posts
  Comment.find_or_create_by!(
    post: android_notifications_post,
    creator: sarah_user,
    organization: innovatelabs_org
  ) do |comment|
    comment.body = "Thanks for reporting this! We'll prioritize the Android notification fix in our next sprint."
    comment.created_at = 20.hours.ago
  end

  Comment.find_or_create_by!(
    post: figma_integration_post,
    creator: david_user,
    organization: innovatelabs_org
  ) do |comment|
    comment.body = "This would be a game-changer for our design workflow! Let's explore the Figma API possibilities."
    comment.created_at = 6.hours.ago
  end
end

puts "✅ Seeded comments"
