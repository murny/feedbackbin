# frozen_string_literal: true

puts "Creating comments..."

# Find users by email address
admin_user = User.find_by!(email_address: "shane.murnaghan@feedbackbin.com")
fake_user = User.find_by!(email_address: "fake_user@example.com")
jane_user = User.find_by!(email_address: "jane_doe@example.com")
alex_user = User.find_by!(email_address: "alex.chen@techcorp.com")
maya_user = User.find_by!(email_address: "maya.patel@designstudio.co")
carlos_user = User.find_by!(email_address: "carlos.rodriguez@freelance.dev")
sarah_user = User.find_by!(email_address: "sarah.kim@startup.io")
david_user = User.find_by!(email_address: "david.thompson@agency.com")

# Find posts by title
dark_mode_post = Post.find_by!(title: "Could you please add dark mode")
mobile_app_post = Post.find_by!(title: "Mobile app support")
accessibility_post = Post.find_by!(title: "Accessibility improvements needed")

# Disable comment broadcasting to make seeding faster
Comment.suppressing_turbo_broadcasts do
  # Comments on FeedbackBin dark mode post
  Comment.find_or_create_by!(
    post: dark_mode_post,
    creator: maya_user,
  ) do |comment|
    comment.body = "This is a great suggestion! Dark mode would definitely improve the user experience, especially for those late-night feedback sessions."
    comment.created_at = 12.days.ago
  end

  alex_dark_mode_comment = Comment.find_or_create_by!(
    post: dark_mode_post,
    creator: alex_user,
  ) do |comment|
    comment.body = "I second this! Most modern apps have dark mode now. It would also help with accessibility for users with light sensitivity."
    comment.created_at = 11.days.ago
  end

  # Reply to Alex's comment
  Comment.find_or_create_by!(
    post: dark_mode_post,
    creator: admin_user,
    parent: alex_dark_mode_comment
  ) do |comment|
    comment.body = "Great point about accessibility! We're actually already working on this feature. Should have an update soon."
    comment.created_at = 10.days.ago
  end

  # Another comment on dark mode post
  carlos_dark_mode_comment = Comment.find_or_create_by!(
    post: dark_mode_post,
    creator: carlos_user,
  ) do |comment|
    comment.body = "Would love to see automatic theme switching based on system preferences too!"
    comment.created_at = 9.days.ago
  end

  # Reply to Carlos's comment
  Comment.find_or_create_by!(
    post: dark_mode_post,
    creator: maya_user,
    parent: carlos_dark_mode_comment
  ) do |comment|
    comment.body = "That's a fantastic UX detail! Auto-switching would make the experience seamless."
    comment.created_at = 8.days.ago
  end

  # Reply to Maya's reply (nested conversation)
  Comment.find_or_create_by!(
    post: dark_mode_post,
    creator: sarah_user,
    parent: carlos_dark_mode_comment
  ) do |comment|
    comment.body = "Agreed! Also, could we have different dark mode variants? Some users prefer pure black vs dark gray themes."
    comment.created_at = 7.days.ago
  end

  # Another standalone comment
  Comment.find_or_create_by!(
    post: dark_mode_post,
    creator: jane_user,
  ) do |comment|
    comment.body = "This feature would be especially helpful for our night shift team members who are always reviewing feedback late at night."
    comment.created_at = 5.days.ago
  end

  # Comments on mobile app post
  Comment.find_or_create_by!(
    post: mobile_app_post,
    creator: carlos_user,
  ) do |comment|
    comment.body = "A mobile app would be fantastic! I'm often reviewing feedback while commuting and the mobile web experience could be better."
    comment.created_at = 13.days.ago
  end

  # Comments on accessibility post
  Comment.find_or_create_by!(
    post: accessibility_post,
    creator: sarah_user,
  ) do |comment|
    comment.body = "Thank you for bringing this up! Accessibility should be a priority. Would you be interested in helping us conduct a full accessibility audit?"
    comment.created_at = 6.days.ago
  end

  # Additional comments on accessibility post
  Comment.find_or_create_by!(
    post: accessibility_post,
    creator: alex_user,
  ) do |comment|
    comment.body = "I'd be happy to help with testing! I have experience with screen readers and can provide detailed feedback."
    comment.created_at = 5.days.ago
  end

  Comment.find_or_create_by!(
    post: accessibility_post,
    creator: maya_user,
  ) do |comment|
    comment.body = "From a design perspective, we should also look at implementing focus indicators and ensuring proper heading hierarchy."
    comment.created_at = 4.days.ago
  end

  # Find additional FeedbackBin posts for comments
  slack_integration_post = Post.find_by!(title: "Slack integration for notifications")
  public_api_post = Post.find_by!(title: "Public API for integrations")
  analytics_dashboard_post = Post.find_by!(title: "Advanced analytics dashboard")
  collaboration_features_post = Post.find_by!(title: "Better collaboration features")

  # Comments on Slack integration post
  Comment.find_or_create_by!(
    post: slack_integration_post,
    creator: carlos_user,
  ) do |comment|
    comment.body = "This would be a game changer! We miss so many updates because we don't check the app frequently enough."
    comment.created_at = 10.days.ago
  end

  Comment.find_or_create_by!(
    post: slack_integration_post,
    creator: jane_user,
  ) do |comment|
    comment.body = "Could we also get Slack commands for creating posts? Something like `/feedback [title] [description]` would be super convenient."
    comment.created_at = 9.days.ago
  end

  Comment.find_or_create_by!(
    post: slack_integration_post,
    creator: sarah_user,
  ) do |comment|
    comment.body = "Teams integration would be great too for organizations using Microsoft's ecosystem!"
    comment.created_at = 8.days.ago
  end

  # Comments on Public API post with threaded replies
  david_api_comment = Comment.find_or_create_by!(
    post: public_api_post,
    creator: david_user,
  ) do |comment|
    comment.body = "This is exactly what we need! Are you planning REST API, GraphQL, or both? Also, what about rate limiting and authentication?"
    comment.created_at = 25.minutes.ago
  end

  # Reply to David's API comment
  Comment.find_or_create_by!(
    post: public_api_post,
    creator: admin_user,
    parent: david_api_comment
  ) do |comment|
    comment.body = "We're planning to start with REST API using API key authentication. GraphQL might come later based on demand. Rate limiting will be generous for legitimate use cases."
    comment.created_at = 20.minutes.ago
  end

  # Another reply to David's comment
  Comment.find_or_create_by!(
    post: public_api_post,
    creator: carlos_user,
    parent: david_api_comment
  ) do |comment|
    comment.body = "Documentation will be crucial! Hope you'll have OpenAPI specs and SDK examples in popular languages."
    comment.created_at = 15.minutes.ago
  end

  # Additional standalone comment on API post
  Comment.find_or_create_by!(
    post: public_api_post,
    creator: maya_user,
  ) do |comment|
    comment.body = "Webhook support would be amazing too! We'd love to trigger actions in our design tools when feedback status changes."
    comment.created_at = 10.minutes.ago
  end

  # Comments on analytics dashboard post
  Comment.find_or_create_by!(
    post: analytics_dashboard_post,
    creator: alex_user,
  ) do |comment|
    comment.body = "Love this idea! Sentiment analysis of feedback would also be valuable to understand user satisfaction trends."
    comment.created_at = 4.hours.ago
  end

  Comment.find_or_create_by!(
    post: analytics_dashboard_post,
    creator: jane_user,
  ) do |comment|
    comment.body = "Custom date ranges and the ability to filter by user segments would make this perfect for our quarterly reviews."
    comment.created_at = 3.hours.ago
  end

  # Comments on collaboration features post
  Comment.find_or_create_by!(
    post: collaboration_features_post,
    creator: maya_user,
  ) do |comment|
    comment.body = "The @mentions feature would be incredibly helpful! Right now we have to remember to manually notify team members about relevant feedback."
    comment.created_at = 20.hours.ago
  end

  Comment.find_or_create_by!(
    post: collaboration_features_post,
    creator: fake_user,
  ) do |comment|
    comment.body = "Internal notes are a must-have! Sometimes we need to discuss implementation details that shouldn't be visible to the feedback author."
    comment.created_at = 18.hours.ago
  end
end

puts "✅ Seeded comments"
