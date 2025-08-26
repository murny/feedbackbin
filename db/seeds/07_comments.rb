# frozen_string_literal: true

puts "Creating comments..."

# Disable comment broadcasting to make seeding faster
Comment.suppressing_turbo_broadcasts do
  # Comments on FeedbackBin dark mode post
  Comment.find_or_create_by!(
    post: $seed_posts[:feedbackbin][:dark_mode],
    creator: $seed_users[:maya],
    organization: $seed_organizations[:feedbackbin]
  ) do |comment|
    comment.body = "This is a great suggestion! Dark mode would definitely improve the user experience, especially for those late-night feedback sessions."
    comment.created_at = 12.days.ago
  end

  Comment.find_or_create_by!(
    post: $seed_posts[:feedbackbin][:dark_mode],
    creator: $seed_users[:alex],
    organization: $seed_organizations[:feedbackbin]
  ) do |comment|
    comment.body = "I second this! Most modern apps have dark mode now. It would also help with accessibility for users with light sensitivity."
    comment.created_at = 11.days.ago
  end

  # Comments on mobile app post
  Comment.find_or_create_by!(
    post: $seed_posts[:feedbackbin][:mobile],
    creator: $seed_users[:carlos],
    organization: $seed_organizations[:feedbackbin]
  ) do |comment|
    comment.body = "A mobile app would be fantastic! I'm often reviewing feedback while commuting and the mobile web experience could be better."
    comment.created_at = 13.days.ago
  end

  # Comments on accessibility post
  Comment.find_or_create_by!(
    post: $seed_posts[:feedbackbin][:accessibility],
    creator: $seed_users[:sarah],
    organization: $seed_organizations[:feedbackbin]
  ) do |comment|
    comment.body = "Thank you for bringing this up! Accessibility should be a priority. Would you be interested in helping us conduct a full accessibility audit?"
    comment.created_at = 6.days.ago
  end

  # Comments on TechCorp posts
  Comment.find_or_create_by!(
    post: $seed_posts[:techcorp][:dashboard],
    creator: $seed_users[:maya],
    organization: $seed_organizations[:techcorp]
  ) do |comment|
    comment.body = "I've noticed the same issue. We should look into implementing lazy loading for the project cards."
    comment.created_at = 1.day.ago
  end

  # Comments on InnovateLabs posts
  Comment.find_or_create_by!(
    post: $seed_posts[:innovatelabs][:android_notifications],
    creator: $seed_users[:sarah],
    organization: $seed_organizations[:innovatelabs]
  ) do |comment|
    comment.body = "Thanks for reporting this! We'll prioritize the Android notification fix in our next sprint."
    comment.created_at = 20.hours.ago
  end

  Comment.find_or_create_by!(
    post: $seed_posts[:innovatelabs][:figma_integration],
    creator: $seed_users[:david],
    organization: $seed_organizations[:innovatelabs]
  ) do |comment|
    comment.body = "This would be a game-changer for our design workflow! Let's explore the Figma API possibilities."
    comment.created_at = 6.hours.ago
  end
end

total_comments = Comment.count
puts "✅ Created #{total_comments} comments across all organizations"