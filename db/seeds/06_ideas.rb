# frozen_string_literal: true

puts "Creating ideas..."

# Find boards
customer_feedback = Board.find_by!(name: "Customer Feedback")
bug_reports = Board.find_by!(name: "Bug Reports")
feature_requests = Board.find_by!(name: "Feature Requests")
ui_ux = Board.find_by!(name: "UI/UX Feedback")

# Find users by email
admin_user = User.find_by!(email_address: "shane.murnaghan@feedbackbin.com")
jane_user = User.find_by!(email_address: "jane_doe@example.com")
alex_user = User.find_by!(email_address: "alex.chen@techcorp.com")
maya_user = User.find_by!(email_address: "maya.patel@designstudio.co")
carlos_user = User.find_by!(email_address: "carlos.rodriguez@freelance.dev")
sarah_user = User.find_by!(email_address: "sarah.kim@startup.io")
david_user = User.find_by!(email_address: "david.thompson@agency.com")

# Disable idea broadcasting to make seeding faster
Idea.suppressing_turbo_broadcasts do
  Idea.find_or_create_by!(
    board: customer_feedback,
    creator: admin_user,
    title: "Could you please add dark mode"
  ) do |idea|
    idea.body = "I would love to see dark mode on this site, please give support for it"
    idea.created_at = 13.days.ago
  end

  Idea.find_or_create_by!(
    board: customer_feedback,
    creator: admin_user,
    title: "Multiple boards"
  ) do |idea|
    idea.body = "I would like to be able to create multiple boards, is this possible?"
    idea.created_at = 9.days.ago
  end

  Idea.find_or_create_by!(
    board: feature_requests,
    creator: maya_user,
    title: "Mobile app support"
  ) do |idea|
    idea.body = "As a UX designer, I'd love to see a dedicated mobile app. The responsive web version is good, but a native app "\
                "would provide better user engagement and push notifications for important updates. This would be especially "\
                "valuable for teams that need to stay on top of feedback while on the go."
    idea.created_at = 14.days.ago
  end

  Idea.find_or_create_by!(
    board: feature_requests,
    creator: alex_user,
    title: "Slack integration for notifications"
  ) do |idea|
    idea.body = "Our team lives in Slack and it would be incredibly helpful to get notifications there when new ideas are "\
                "posted or when status updates occur. Maybe even the ability to create quick ideas directly from Slack? This "\
                "would streamline our workflow significantly."
    idea.created_at = 11.days.ago
  end

  Idea.find_or_create_by!(
    board: bug_reports,
    creator: carlos_user,
    title: "Search functionality not working with special characters"
  ) do |idea|
    idea.body = "I've noticed that when searching for ideas containing special characters like @ or #, the search returns no "\
                "results even though I know ideas exist with those characters. This is particularly problematic when "\
                "searching for user mentions or hashtags."
    idea.created_at = 2.hours.ago
  end

  Idea.find_or_create_by!(
    board: ui_ux,
    creator: david_user,
    title: "Accessibility improvements needed"
  ) do |idea|
    idea.body = "As someone who cares deeply about digital accessibility, I've noticed several areas where this platform "\
                "could be improved:\n\n1. Some buttons lack proper ARIA labels\n2. Color contrast could be better in dark "\
                "mode\n3. Keyboard navigation is inconsistent in some areas\n4. Screen reader support could be enhanced\n\n"\
                "I'd be happy to help audit and provide specific recommendations!"
    idea.created_at = 7.days.ago
  end

  Idea.find_or_create_by!(
    board: feature_requests,
    creator: sarah_user,
    title: "Advanced analytics dashboard"
  ) do |idea|
    idea.body = "As a product owner, I need better insights into our feedback data. It would be amazing to have:\n\n- "\
                "Trending topics analysis\n- User engagement metrics\n- Feedback resolution time tracking\n- Export "\
                "capabilities for executive reports\n- Integration with Google Analytics or similar tools\n\nThis would "\
                "help us make more data-driven product decisions."
    idea.created_at = 6.hours.ago
  end

  Idea.find_or_create_by!(
    board: feature_requests,
    creator: jane_user,
    title: "Better collaboration features"
  ) do |idea|
    idea.body = "I think we need better ways to collaborate on ideas. Some ideas:\n\n- Ability to assign ideas to "\
                "team members\n- Internal notes that aren't visible to customers\n- @mentions in comments\n- Status change "\
                "notifications\n- Due dates for ideas"
    idea.created_at = 1.day.ago
  end

  Idea.find_or_create_by!(
    board: ui_ux,
    creator: maya_user,
    title: "More customization options for brands"
  ) do |idea|
    idea.body = "Our clients want their feedback portals to match their brand identity. We need:\n\n- Custom color schemes "\
                "beyond the current options\n- Logo upload capabilities\n- Custom CSS injection (for advanced users)\n- "\
                "White-label options\n- Custom domain support\n\nThis would make the platform much more appealing to "\
                "enterprise clients."
    idea.created_at = 4.days.ago
  end

  Idea.find_or_create_by!(
    board: bug_reports,
    creator: carlos_user,
    title: "Page load times are slow with large datasets"
  ) do |idea|
    idea.body = "I've been testing with accounts that have 1000+ ideas, and the performance degrades "\
                "significantly. The main issues I've noticed:\n\n- Initial page load takes 5-8 seconds\n- Scrolling "\
                "through ideas is janky\n- Search becomes very slow\n- Browser sometimes becomes unresponsive\n\nMight "\
                "need pagination or virtualization for better performance."
    idea.created_at = 3.days.ago
  end

  Idea.find_or_create_by!(
    board: feature_requests,
    creator: alex_user,
    title: "Public API for integrations"
  ) do |idea|
    idea.body = "We'd love to integrate FeedbackBin with our existing product management tools like Jira, Linear, and "\
                "Monday.com. A REST API would enable us to:\n\n- Automatically sync ideas with our roadmap\n- Create "\
                "tickets from high-priority ideas\n- Update statuses from external tools\n- Build custom dashboards\n\n"\
                "This would make FeedbackBin the central hub for all our user feedback!"
    idea.created_at = 30.minutes.ago
  end
end

puts "✅ Seeded ideas"
