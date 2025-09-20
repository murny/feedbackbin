# frozen_string_literal: true

puts "Creating posts for Hooli tenant..."

ApplicationRecord.with_tenant("hooli") do
  # Find categories and users within this tenant
  hooli_xyz = Category.find_by!(name: "Hooli XYZ")
  hooliphone = Category.find_by!(name: "HooliPhone")
  box_initiative = Category.find_by!(name: "Box Initiative")
  platform = Category.find_by!(name: "Platform & Infrastructure")
  culture = Category.find_by!(name: "Workplace Culture")

  gavin_user = User.find_by!(email_address: "gavin.belson@hooli.com")
  jack_user = User.find_by!(email_address: "jack.barker@hooli.com")
  denpok_user = User.find_by!(email_address: "denpok@hooli.com")
  jeff_user = User.find_by!(email_address: "jeff.hartman@hooli.com")
  patrice_user = User.find_by!(email_address: "patrice.henderson@hooli.com")
  ben_user = User.find_by!(email_address: "ben.rogers@hooli.com")
  tracy_user = User.find_by!(email_address: "tracy.williams@hooli.com")

  # Disable post broadcasting to make seeding faster
  Post.suppressing_turbo_broadcasts do
    Post.find_or_create_by!(
      category: hooli_xyz,
      author: gavin_user,
      title: "Making the world a better place - Vision for Hooli XYZ 2.0"
    ) do |post|
      post.body = "Team, as we continue our mission to make the world a better place through minimal message-oriented transport "\
                  "layers, I want to share my vision for Hooli XYZ 2.0. We need to disrupt the disruption and create "\
                  "synergies that will revolutionize how humans interface with technology. Let's ideate some blue-sky "\
                  "thinking around this initiative."
      post.created_at = 5.days.ago
    end

    Post.find_or_create_by!(
      category: box_initiative,
      author: jack_user,
      title: "Box Strategy - Let's circle back and action this"
    ) do |post|
      post.body = "I've been deep-diving into our Box initiative and I think we need to pivot our go-to-market strategy. "\
                  "Let's leverage our core competencies and create a paradigm shift in the connectivity space. We should "\
                  "schedule an all-hands to discuss bandwidth and resource allocation. This could be a real game-changer "\
                  "if we execute correctly."
      post.created_at = 3.days.ago
    end

    Post.find_or_create_by!(
      category: culture,
      author: denpok_user,
      title: "Mindfulness Integration in Daily Standup Meetings"
    ) do |post|
      post.body = "I propose we begin each standup with a moment of mindfulness. Research shows that 60 seconds of "\
                  "meditation can increase productivity by 23% and reduce workplace stress. We could introduce breathing "\
                  "exercises and perhaps some light chanting to center the team before discussing sprint goals. "\
                  "Inner peace leads to better code."
      post.created_at = 7.days.ago
    end

    Post.find_or_create_by!(
      category: hooliphone,
      author: jeff_user,
      title: "HooliPhone battery optimization issues"
    ) do |post|
      post.body = "I've been testing the HooliPhone prototype and noticed significant battery drain when running our "\
                  "proprietary apps. The background processes for Hooli XYZ integration seem to be consuming more power "\
                  "than expected. This could impact our user experience metrics when we launch. We need to optimize "\
                  "the power management algorithms."
      post.created_at = 2.days.ago
    end

    Post.find_or_create_by!(
      category: platform,
      author: patrice_user,
      title: "Scalability concerns for Q4 user growth projections"
    ) do |post|
      post.body = "Based on our aggressive user acquisition targets for Q4, we need to address potential scalability "\
                  "bottlenecks in our core platform. The current architecture may not handle the projected 500% user "\
                  "growth without significant infrastructure investments. We should consider cloud migration strategies "\
                  "and microservices architecture to future-proof our platform."
      post.created_at = 1.day.ago
    end

    Post.find_or_create_by!(
      category: platform,
      author: ben_user,
      title: "Security audit findings - Urgent action required"
    ) do |post|
      post.body = "Our recent security audit revealed several critical vulnerabilities in our user authentication system. "\
                  "We need immediate remediation to prevent potential data breaches. The findings include weak password "\
                  "policies, insufficient encryption, and possible SQL injection vectors. I recommend we implement "\
                  "two-factor authentication and conduct penetration testing monthly."
      post.created_at = 4.hours.ago
    end

    Post.find_or_create_by!(
      category: hooliphone,
      author: tracy_user,
      title: "HooliPhone UI inconsistencies across different screen sizes"
    ) do |post|
      post.body = "I've been conducting usability testing on the HooliPhone interface and discovered several UI "\
                  "inconsistencies. The navigation elements don't scale properly on larger screens, and some buttons "\
                  "are difficult to reach with one-handed operation. We need to establish better design guidelines "\
                  "and create responsive layouts that work across all device sizes."
      post.created_at = 6.hours.ago
    end

    Post.find_or_create_by!(
      category: box_initiative,
      author: gavin_user,
      title: "Box 3.0 - Connecting the unconnected"
    ) do |post|
      post.body = "The Box initiative represents the future of human connectivity. Box 3.0 will not just connect devices, "\
                  "but connect souls. We're building more than technology - we're building bridges between human "\
                  "consciousness and digital transcendence. This isn't just about market penetration; this is about "\
                  "elevating humanity to its next evolutionary stage."
      post.created_at = 12.hours.ago
    end

    Post.find_or_create_by!(
      category: culture,
      author: denpok_user,
      title: "Proposal for Rooftop Meditation Garden"
    ) do |post|
      post.body = "I envision transforming our rooftop space into a tranquil meditation garden where Hooli employees "\
                  "can find inner peace and spiritual clarity. The garden would feature zen rock arrangements, "\
                  "flowing water features, and spaces for group meditation sessions. This investment in our team's "\
                  "spiritual well-being will pay dividends in creativity and innovation."
      post.created_at = 8.days.ago
    end

    Post.find_or_create_by!(
      category: hooli_xyz,
      author: patrice_user,
      title: "XYZ API rate limiting causing integration failures"
    ) do |post|
      post.body = "Several enterprise clients are reporting integration failures with our XYZ API due to aggressive "\
                  "rate limiting. The current limits of 100 requests per minute are insufficient for high-volume "\
                  "applications. We risk losing major contracts if we don't address this soon. I recommend increasing "\
                  "limits for enterprise tiers and implementing more granular throttling."
      post.created_at = 30.minutes.ago
    end
  end
end

puts "✅ Seeded posts for Hooli tenant"