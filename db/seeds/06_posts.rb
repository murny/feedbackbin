# frozen_string_literal: true

puts "Creating posts..."

# Disable post broadcasting to make seeding faster
Post.suppressing_turbo_broadcasts do
  # FeedbackBin posts
  feedbackbin_dark_mode = Post.find_or_create_by!(organization: $seed_organizations[:feedbackbin], category: $seed_categories[:feedbackbin][:customer_feedback], author: $seed_users[:admin], title: "Could you please add dark mode") do |post|
    post.body = "I would love to see dark mode on this site, please give support for it"
    post.created_at = 13.days.ago
  end

  $seed_categories[:feedbackbin][:customer_feedback].posts.find_or_create_by!(organization: $seed_organizations[:feedbackbin], title: "Multiple categories") do |post|
    post.body = "I would like to be able to create multiple categories, is this possible?"
    post.author = $seed_users[:admin]
    post.created_at = 9.days.ago
  end

  feedbackbin_mobile = Post.find_or_create_by!(organization: $seed_organizations[:feedbackbin], category: $seed_categories[:feedbackbin][:feature_requests], author: $seed_users[:maya], title: "Mobile app support") do |post|
    post.body = "As a UX designer, I'd love to see a dedicated mobile app. The responsive web version is good, but a native app would provide better user engagement and push notifications for important updates. This would be especially valuable for teams that need to stay on top of feedback while on the go."
    post.created_at = 14.days.ago
  end

  feedbackbin_integrations = Post.find_or_create_by!(organization: $seed_organizations[:feedbackbin], category: $seed_categories[:feedbackbin][:feature_requests], author: $seed_users[:alex], title: "Slack integration for notifications") do |post|
    post.body = "Our team lives in Slack and it would be incredibly helpful to get notifications there when new feedback is posted or when status updates occur. Maybe even the ability to create quick posts directly from Slack? This would streamline our workflow significantly."
    post.created_at = 11.days.ago
  end

  feedbackbin_bug_search = Post.find_or_create_by!(organization: $seed_organizations[:feedbackbin], category: $seed_categories[:feedbackbin][:bug_reports], author: $seed_users[:carlos], title: "Search functionality not working with special characters") do |post|
    post.body = "I've noticed that when searching for posts containing special characters like @ or #, the search returns no results even though I know posts exist with those characters. This is particularly problematic when searching for user mentions or hashtags."
    post.created_at = 2.hours.ago
  end

  feedbackbin_accessibility = Post.find_or_create_by!(organization: $seed_organizations[:feedbackbin], category: $seed_categories[:feedbackbin][:ui_ux], author: $seed_users[:david], title: "Accessibility improvements needed") do |post|
    post.body = "As someone who cares deeply about digital accessibility, I've noticed several areas where this platform could be improved:\n\n1. Some buttons lack proper ARIA labels\n2. Color contrast could be better in dark mode\n3. Keyboard navigation is inconsistent in some areas\n4. Screen reader support could be enhanced\n\nI'd be happy to help audit and provide specific recommendations!"
    post.created_at = 7.days.ago
  end

  feedbackbin_analytics = Post.find_or_create_by!(organization: $seed_organizations[:feedbackbin], category: $seed_categories[:feedbackbin][:feature_requests], author: $seed_users[:sarah], title: "Advanced analytics dashboard") do |post|
    post.body = "As a product owner, I need better insights into our feedback data. It would be amazing to have:\n\n- Trending topics analysis\n- User engagement metrics\n- Feedback resolution time tracking\n- Export capabilities for executive reports\n- Integration with Google Analytics or similar tools\n\nThis would help us make more data-driven product decisions."
    post.created_at = 6.hours.ago
  end

  feedbackbin_collaboration = Post.find_or_create_by!(organization: $seed_organizations[:feedbackbin], category: $seed_categories[:feedbackbin][:feature_requests], author: $seed_users[:user_two], title: "Better collaboration features") do |post|
    post.body = "I think we need better ways to collaborate on feedback items. Some ideas:\n\n- Ability to assign posts to team members\n- Internal notes that aren't visible to customers\n- @mentions in comments\n- Status change notifications\n- Due dates for feedback items"
    post.created_at = 1.day.ago
  end

  feedbackbin_customization = Post.find_or_create_by!(organization: $seed_organizations[:feedbackbin], category: $seed_categories[:feedbackbin][:ui_ux], author: $seed_users[:maya], title: "More customization options for brands") do |post|
    post.body = "Our clients want their feedback portals to match their brand identity. We need:\n\n- Custom color schemes beyond the current options\n- Logo upload capabilities\n- Custom CSS injection (for advanced users)\n- White-label options\n- Custom domain support\n\nThis would make the platform much more appealing to enterprise clients."
    post.created_at = 4.days.ago
  end

  feedbackbin_performance = Post.find_or_create_by!(organization: $seed_organizations[:feedbackbin], category: $seed_categories[:feedbackbin][:bug_reports], author: $seed_users[:carlos], title: "Page load times are slow with large datasets") do |post|
    post.body = "I've been testing with organizations that have 1000+ feedback posts, and the performance degrades significantly. The main issues I've noticed:\n\n- Initial page load takes 5-8 seconds\n- Scrolling through posts is janky\n- Search becomes very slow\n- Browser sometimes becomes unresponsive\n\nMight need pagination or virtualization for better performance."
    post.created_at = 3.days.ago
  end

  feedbackbin_api = Post.find_or_create_by!(organization: $seed_organizations[:feedbackbin], category: $seed_categories[:feedbackbin][:feature_requests], author: $seed_users[:alex], title: "Public API for integrations") do |post|
    post.body = "We'd love to integrate FeedbackBin with our existing product management tools like Jira, Linear, and Monday.com. A REST API would enable us to:\n\n- Automatically sync feedback with our roadmap\n- Create tickets from high-priority feedback\n- Update statuses from external tools\n- Build custom dashboards\n\nThis would make FeedbackBin the central hub for all our user feedback!"
    post.created_at = 30.minutes.ago
  end

  # TechCorp posts
  techcorp_dashboard = Post.find_or_create_by!(organization: $seed_organizations[:techcorp], category: $seed_categories[:techcorp][:product], author: $seed_users[:alex], title: "Dashboard performance improvements") do |post|
    post.body = "Our team dashboard is loading slowly when we have many active projects. Can we optimize this for better performance?"
    post.created_at = 2.days.ago
  end

  techcorp_api_limits = Post.find_or_create_by!(organization: $seed_organizations[:techcorp], category: $seed_categories[:techcorp][:engineering], author: $seed_users[:carlos], title: "API rate limiting issues") do |post|
    post.body = "We're hitting rate limits on the API more frequently. Could we increase the limits or implement better caching?"
    post.created_at = 5.hours.ago
  end

  techcorp_onboarding = Post.find_or_create_by!(organization: $seed_organizations[:techcorp], category: $seed_categories[:techcorp][:product], author: $seed_users[:maya], title: "User onboarding flow feedback") do |post|
    post.body = "The current onboarding process has some UX issues. Users are dropping off at step 3. We need to simplify the flow."
    post.created_at = 1.day.ago
  end

  # InnovateLabs posts
  innovatelabs_notifications = Post.find_or_create_by!(organization: $seed_organizations[:innovatelabs], category: $seed_categories[:innovatelabs][:mobile], author: $seed_users[:admin], title: "Push notifications not working on Android") do |post|
    post.body = "I've been testing the mobile app and push notifications aren't coming through on my Android device. They work fine on iOS though. This is affecting my ability to stay updated on important feedback."
    post.created_at = 1.day.ago
  end

  innovatelabs_collaboration = Post.find_or_create_by!(organization: $seed_organizations[:innovatelabs], category: $seed_categories[:innovatelabs][:platform], author: $seed_users[:maya], title: "Real-time collaboration features") do |post|
    post.body = "Would love to see real-time collaboration features like live cursors, presence indicators, and instant comment updates. This would make our design review process much smoother."
    post.created_at = 3.hours.ago
  end

  innovatelabs_figma = Post.find_or_create_by!(organization: $seed_organizations[:innovatelabs], category: $seed_categories[:innovatelabs][:integrations], author: $seed_users[:user], title: "Figma integration for design handoffs") do |post|
    post.body = "It would be amazing to have a Figma integration that automatically syncs design specs and allows developers to leave feedback directly on design components."
    post.created_at = 8.hours.ago
  end

  innovatelabs_search = Post.find_or_create_by!(organization: $seed_organizations[:innovatelabs], category: $seed_categories[:innovatelabs][:platform], author: $seed_users[:alex], title: "Improved search with filters") do |post|
    post.body = "The current search is basic. We need advanced filters like date ranges, author, status, and category to help us find relevant feedback quickly in our growing database."
    post.created_at = 2.days.ago
  end

  innovatelabs_dark_mode = Post.find_or_create_by!(organization: $seed_organizations[:innovatelabs], category: $seed_categories[:innovatelabs][:mobile], author: $seed_users[:user], title: "Dark mode inconsistencies in mobile app") do |post|
    post.body = "The mobile app's dark mode has some UI inconsistencies. Some buttons are still showing light theme colors and the contrast isn't great in certain areas."
    post.created_at = 30.minutes.ago
  end

  # Store posts for engagement seed file
  $seed_posts = {
    feedbackbin: {
      dark_mode: feedbackbin_dark_mode,
      mobile: feedbackbin_mobile,
      integrations: feedbackbin_integrations,
      bug_search: feedbackbin_bug_search,
      accessibility: feedbackbin_accessibility,
      analytics: feedbackbin_analytics,
      collaboration: feedbackbin_collaboration,
      customization: feedbackbin_customization,
      performance: feedbackbin_performance,
      api: feedbackbin_api
    },
    techcorp: {
      dashboard: techcorp_dashboard,
      api_limits: techcorp_api_limits,
      onboarding: techcorp_onboarding
    },
    innovatelabs: {
      android_notifications: innovatelabs_notifications,
      realtime_collab: innovatelabs_collaboration,
      figma_integration: innovatelabs_figma,
      advanced_search: innovatelabs_search,
      mobile_dark_mode: innovatelabs_dark_mode
    }
  }
end

puts "✅ Created posts for organizations:"
puts "   - FeedbackBin: #{$seed_posts[:feedbackbin].count} posts"
puts "   - TechCorp: #{$seed_posts[:techcorp].count} posts"
puts "   - InnovateLabs: #{$seed_posts[:innovatelabs].count} posts"