# frozen_string_literal: true

puts "Creating likes..."

# Likes on FeedbackBin posts
Like.find_or_create_by!(
  likeable: $seed_posts[:feedbackbin][:dark_mode],
  voter: $seed_users[:maya],
  organization: $seed_organizations[:feedbackbin]
)

Like.find_or_create_by!(
  likeable: $seed_posts[:feedbackbin][:dark_mode],
  voter: $seed_users[:alex],
  organization: $seed_organizations[:feedbackbin]
)

Like.find_or_create_by!(
  likeable: $seed_posts[:feedbackbin][:dark_mode],
  voter: $seed_users[:carlos],
  organization: $seed_organizations[:feedbackbin]
)

Like.find_or_create_by!(
  likeable: $seed_posts[:feedbackbin][:mobile],
  voter: $seed_users[:carlos],
  organization: $seed_organizations[:feedbackbin]
)

Like.find_or_create_by!(
  likeable: $seed_posts[:feedbackbin][:mobile],
  voter: $seed_users[:david],
  organization: $seed_organizations[:feedbackbin]
)

Like.find_or_create_by!(
  likeable: $seed_posts[:feedbackbin][:accessibility],
  voter: $seed_users[:sarah],
  organization: $seed_organizations[:feedbackbin]
)

Like.find_or_create_by!(
  likeable: $seed_posts[:feedbackbin][:accessibility],
  voter: $seed_users[:maya],
  organization: $seed_organizations[:feedbackbin]
)

Like.find_or_create_by!(
  likeable: $seed_posts[:feedbackbin][:api],
  voter: $seed_users[:alex],
  organization: $seed_organizations[:feedbackbin]
)

Like.find_or_create_by!(
  likeable: $seed_posts[:feedbackbin][:api],
  voter: $seed_users[:maya],
  organization: $seed_organizations[:feedbackbin]
)

Like.find_or_create_by!(
  likeable: $seed_posts[:feedbackbin][:api],
  voter: $seed_users[:sarah],
  organization: $seed_organizations[:feedbackbin]
)

# Likes on TechCorp posts
Like.find_or_create_by!(
  likeable: $seed_posts[:techcorp][:dashboard],
  voter: $seed_users[:maya],
  organization: $seed_organizations[:techcorp]
)

Like.find_or_create_by!(
  likeable: $seed_posts[:techcorp][:dashboard],
  voter: $seed_users[:carlos],
  organization: $seed_organizations[:techcorp]
)

# Likes on InnovateLabs posts
Like.find_or_create_by!(
  likeable: $seed_posts[:innovatelabs][:figma_integration],
  voter: $seed_users[:david],
  organization: $seed_organizations[:innovatelabs]
)

Like.find_or_create_by!(
  likeable: $seed_posts[:innovatelabs][:figma_integration],
  voter: $seed_users[:maya],
  organization: $seed_organizations[:innovatelabs]
)

Like.find_or_create_by!(
  likeable: $seed_posts[:innovatelabs][:realtime_collab],
  voter: $seed_users[:admin],
  organization: $seed_organizations[:innovatelabs]
)

total_likes = Like.count
puts "✅ Created #{total_likes} likes across all organizations"