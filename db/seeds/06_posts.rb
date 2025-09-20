# frozen_string_literal: true

puts "Creating posts..."

# Find categories for each organization
customer_feedback = Category.find_by!(name: "Customer Feedback")
bug_reports = Category.find_by!(name: "Bug Reports")
feature_requests = Category.find_by!(name: "Feature Requests")
ui_ux = Category.find_by!(name: "UI/UX Feedback")

# Find users by email
admin_user = User.find_by!(email_address: "shane.murnaghan@feedbackbin.com")
jane_user = User.find_by!(email_address: "jane_doe@example.com")
alex_user = User.find_by!(email_address: "alex.chen@techcorp.com")
maya_user = User.find_by!(email_address: "maya.patel@designstudio.co")
carlos_user = User.find_by!(email_address: "carlos.rodriguez@freelance.dev")
sarah_user = User.find_by!(email_address: "sarah.kim@startup.io")
david_user = User.find_by!(email_address: "david.thompson@agency.com")

# Disable post broadcasting to make seeding faster
Post.suppressing_turbo_broadcasts do
  Post.find_or_create_by!(
    category: customer_feedback,
    author: admin_user,
    title: "Could you please add dark mode"
  ) do |post|
    post.body = "I would love to see dark mode on this site, please give support for it"
    post.created_at = 13.days.ago
  end

  Post.find_or_create_by!(
    category: customer_feedback,
    author: admin_user,
    title: "Multiple categories"
  ) do |post|
    post.body = "I would like to be able to create multiple categories, is this possible?"
    post.created_at = 9.days.ago
  end

  Post.find_or_create_by!(
    category: feature_requests,
    author: maya_user,
    title: "Mobile app support"
  ) do |post|
    post.body = "As a UX designer, I'd love to see a dedicated mobile app. The responsive web version is good, but a native app "\
                "would provide better user engagement and push notifications for important updates. This would be especially "\
                "valuable for teams that need to stay on top of feedback while on the go."
    post.created_at = 14.days.ago
  end

  Post.find_or_create_by!(
    category: feature_requests,
    author: alex_user,
    title: "Slack integration for notifications"
  ) do |post|
    post.body = "Our team lives in Slack and it would be incredibly helpful to get notifications there when new feedback is "\
                "posted or when status updates occur. Maybe even the ability to create quick posts directly from Slack? This "\
                "would streamline our workflow significantly."
    post.created_at = 11.days.ago
  end

  Post.find_or_create_by!(
    category: bug_reports,
    author: carlos_user,
    title: "Search functionality not working with special characters"
  ) do |post|
    post.body = "I've noticed that when searching for posts containing special characters like @ or #, the search returns no "\
                "results even though I know posts exist with those characters. This is particularly problematic when "\
                "searching for user mentions or hashtags."
    post.created_at = 2.hours.ago
  end

  Post.find_or_create_by!(
    category: ui_ux,
    author: david_user,
    title: "Accessibility improvements needed"
  ) do |post|
    post.body = "As someone who cares deeply about digital accessibility, I've noticed several areas where this platform "\
                "could be improved:\n\n1. Some buttons lack proper ARIA labels\n2. Color contrast could be better in dark "\
                "mode\n3. Keyboard navigation is inconsistent in some areas\n4. Screen reader support could be enhanced\n\n"\
                "I'd be happy to help audit and provide specific recommendations!"
    post.created_at = 7.days.ago
  end

  Post.find_or_create_by!(
    category: feature_requests,
    author: sarah_user,
    title: "Advanced analytics dashboard"
  ) do |post|
    post.body = "As a product owner, I need better insights into our feedback data. It would be amazing to have:\n\n- "\
                "Trending topics analysis\n- User engagement metrics\n- Feedback resolution time tracking\n- Export "\
                "capabilities for executive reports\n- Integration with Google Analytics or similar tools\n\nThis would "\
                "help us make more data-driven product decisions."
    post.created_at = 6.hours.ago
  end

  Post.find_or_create_by!(
    category: feature_requests,
    author: jane_user,
    title: "Better collaboration features"
  ) do |post|
    post.body = "I think we need better ways to collaborate on feedback items. Some ideas:\n\n- Ability to assign posts to "\
                "team members\n- Internal notes that aren't visible to customers\n- @mentions in comments\n- Status change "\
                "notifications\n- Due dates for feedback items"
    post.created_at = 1.day.ago
  end

  Post.find_or_create_by!(
    category: ui_ux,
    author: maya_user,
    title: "More customization options for brands"
  ) do |post|
    post.body = "Our clients want their feedback portals to match their brand identity. We need:\n\n- Custom color schemes "\
                "beyond the current options\n- Logo upload capabilities\n- Custom CSS injection (for advanced users)\n- "\
                "White-label options\n- Custom domain support\n\nThis would make the platform much more appealing to "\
                "enterprise clients."
    post.created_at = 4.days.ago
  end

  Post.find_or_create_by!(
    category: bug_reports,
    author: carlos_user,
    title: "Page load times are slow with large datasets"
  ) do |post|
    post.body = "I've been testing with organizations that have 1000+ feedback posts, and the performance degrades "\
                "significantly. The main issues I've noticed:\n\n- Initial page load takes 5-8 seconds\n- Scrolling "\
                "through posts is janky\n- Search becomes very slow\n- Browser sometimes becomes unresponsive\n\nMight "\
                "need pagination or virtualization for better performance."
    post.created_at = 3.days.ago
  end

  Post.find_or_create_by!(
    category: feature_requests,
    author: alex_user,
    title: "Public API for integrations"
  ) do |post|
    post.body = "We'd love to integrate FeedbackBin with our existing product management tools like Jira, Linear, and "\
                "Monday.com. A REST API would enable us to:\n\n- Automatically sync feedback with our roadmap\n- Create "\
                "tickets from high-priority feedback\n- Update statuses from external tools\n- Build custom dashboards\n\n"\
                "This would make FeedbackBin the central hub for all our user feedback!"
    post.created_at = 30.minutes.ago
  end
end

puts "✅ Seeded posts"
