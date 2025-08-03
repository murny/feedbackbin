# frozen_string_literal: true

puts "Creating comments and likes..."

# Initial comments on dark mode post
Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:dark_mode], creator: $seed_users[:user]) do |comment|
  comment.body = "I would also like to see this feature"
end

comment = Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:dark_mode], creator: $seed_users[:user_two]) do |comment|
  comment.body = "I agree, dark mode would be great"
end

# Replies to the comment
Comment.find_or_create_by!(organization: $seed_organization, parent: comment, post: comment.post, creator: $seed_users[:user]) do |comment|
  comment.body = "I'm glad you agree, I hope the developers see this"
end

Comment.find_or_create_by!(organization: $seed_organization, parent: comment, post: comment.post, creator: $seed_users[:user_two]) do |comment|
  comment.body = "I'm not sure if they will, but I hope so too"
end

# Comments on mobile app post
Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:mobile], creator: $seed_users[:alex]) do |comment|
  comment.body = "Totally agree! Push notifications would be a game changer for our team's response times."
end

Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:mobile], creator: $seed_users[:sarah]) do |comment|
  comment.body = "From a product perspective, we'd also need to consider offline functionality. What happens when users are in areas with poor connectivity?"
end

mobile_reply = Comment.find_or_create_by!(organization: $seed_organization, parent: Comment.find_by(post: $seed_posts[:mobile], creator: $seed_users[:sarah]), post: $seed_posts[:mobile], creator: $seed_users[:maya]) do |comment|
  comment.body = "Great point Sarah! Progressive Web App features could bridge that gap while we develop the native app."
end

Comment.find_or_create_by!(organization: $seed_organization, parent: mobile_reply, post: $seed_posts[:mobile], creator: $seed_users[:carlos]) do |comment|
  comment.body = "PWAs are definitely the way to go initially. Much faster to implement and maintain."
end

# Comments on Slack integration post
Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:integrations], creator: $seed_users[:david]) do |comment|
  comment.body = "This would save us so much time! We currently have to manually check for updates multiple times a day."
end

Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:integrations], creator: $seed_users[:maya]) do |comment|
  comment.body = "Microsoft Teams integration would be valuable too - not all companies use Slack."
end

slack_reply = Comment.find_or_create_by!(organization: $seed_organization, parent: Comment.find_by(post: $seed_posts[:integrations], creator: $seed_users[:maya]), post: $seed_posts[:integrations], creator: $seed_users[:alex]) do |comment|
  comment.body = "Good call on Teams! Discord integration could be interesting for gaming/tech companies too."
end

# Comments on search bug post
Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:bug_search], creator: $seed_users[:admin]) do |comment|
  comment.body = "Thanks for reporting this Carlos! I can reproduce the issue. We'll prioritize this fix since search is critical functionality."
end

Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:bug_search], creator: $seed_users[:david]) do |comment|
  comment.body = "I've seen this too with email addresses in posts. Definitely impacts usability."
end

# Comments on accessibility post
Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:accessibility], creator: $seed_users[:maya]) do |comment|
  comment.body = "This is so important! I'd love to collaborate on this. Accessibility should be a core feature, not an afterthought."
end

Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:accessibility], creator: $seed_users[:sarah]) do |comment|
  comment.body = "Absolutely agree. This could also help us comply with WCAG guidelines which many enterprise clients require."
end

accessibility_reply = Comment.find_or_create_by!(organization: $seed_organization, parent: Comment.find_by(post: $seed_posts[:accessibility], creator: $seed_users[:maya]), post: $seed_posts[:accessibility], creator: $seed_users[:david]) do |comment|
  comment.body = "I can do a full audit next week if that would help. I have experience with JAWS and NVDA screen readers."
end

Comment.find_or_create_by!(organization: $seed_organization, parent: accessibility_reply, post: $seed_posts[:accessibility], creator: $seed_users[:admin]) do |comment|
  comment.body = "That would be amazing David! Let's set up a call to discuss the scope."
end

# Comments on analytics post
Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:analytics], creator: $seed_users[:alex]) do |comment|
  comment.body = "The trending topics analysis would be incredibly valuable for our product roadmap planning!"
end

Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:analytics], creator: $seed_users[:carlos]) do |comment|
  comment.body = "From a technical standpoint, we could implement this with a data pipeline to aggregate and analyze the feedback text."
end

analytics_reply = Comment.find_or_create_by!(organization: $seed_organization, parent: Comment.find_by(post: $seed_posts[:analytics], creator: $seed_users[:carlos]), post: $seed_posts[:analytics], creator: $seed_users[:sarah]) do |comment|
  comment.body = "Exactly! And machine learning could help categorize feedback automatically and identify sentiment trends."
end

# Comments on collaboration post
Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:collaboration], creator: $seed_users[:maya]) do |comment|
  comment.body = "The @mentions feature would be so helpful! Currently we have to remember to manually notify people."
end

Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:collaboration], creator: $seed_users[:alex]) do |comment|
  comment.body = "Internal notes are a great idea. Sometimes we need to discuss technical feasibility without confusing end users."
end

Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:collaboration], creator: $seed_users[:admin]) do |comment|
  comment.body = "All great suggestions! The assignment feature would help with accountability too."
end

# Comments on customization post
Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:customization], creator: $seed_users[:alex]) do |comment|
  comment.body = "White-label options would be huge for enterprise sales. Many clients ask about this during demos."
end

Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:customization], creator: $seed_users[:david]) do |comment|
  comment.body = "Custom CSS injection needs to be carefully implemented to avoid security issues, but it's definitely doable."
end

# Comments on performance post
Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:performance], creator: $seed_users[:maya]) do |comment|
  comment.body = "I've noticed this too in our user testing. Pagination would definitely help, especially on mobile devices."
end

Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:performance], creator: $seed_users[:admin]) do |comment|
  comment.body = "This is a critical issue for scaling. We're looking into implementing virtual scrolling for large datasets."
end

performance_reply = Comment.find_or_create_by!(organization: $seed_organization, parent: Comment.find_by(post: $seed_posts[:performance], creator: $seed_users[:admin]), post: $seed_posts[:performance], creator: $seed_users[:carlos]) do |comment|
  comment.body = "Virtual scrolling would be perfect! Libraries like react-window make this pretty straightforward to implement."
end

# Comments on API post
Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:api], creator: $seed_users[:sarah]) do |comment|
  comment.body = "This would transform how we use FeedbackBin! Being able to sync with our existing workflow tools is essential."
end

Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:api], creator: $seed_users[:david]) do |comment|
  comment.body = "GraphQL might be worth considering alongside REST - would give clients more flexibility in data fetching."
end

Comment.find_or_create_by!(organization: $seed_organization, post: $seed_posts[:api], creator: $seed_users[:maya]) do |comment|
  comment.body = "Webhooks would be valuable too - real-time notifications when feedback status changes."
end

api_reply = Comment.find_or_create_by!(organization: $seed_organization, parent: Comment.find_by(post: $seed_posts[:api], creator: $seed_users[:maya]), post: $seed_posts[:api], creator: $seed_users[:alex]) do |comment|
  comment.body = "Yes! Webhooks would enable so many automation possibilities. We could auto-update our customers when their feedback is addressed."
end

# Add likes to posts and comments to make them feel more realistic

# Likes on the original dark mode post
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:dark_mode], voter: $seed_users[:user])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:dark_mode], voter: $seed_users[:user_two])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:dark_mode], voter: $seed_users[:maya])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:dark_mode], voter: $seed_users[:alex])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:dark_mode], voter: $seed_users[:david])

# Likes on mobile app post (very popular feature request)
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:mobile], voter: $seed_users[:admin])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:mobile], voter: $seed_users[:alex])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:mobile], voter: $seed_users[:sarah])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:mobile], voter: $seed_users[:carlos])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:mobile], voter: $seed_users[:david])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:mobile], voter: $seed_users[:user])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:mobile], voter: $seed_users[:user_two])

# Likes on Slack integration post
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:integrations], voter: $seed_users[:maya])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:integrations], voter: $seed_users[:sarah])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:integrations], voter: $seed_users[:david])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:integrations], voter: $seed_users[:user_two])

# Likes on accessibility post (important but fewer likes)
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:accessibility], voter: $seed_users[:maya])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:accessibility], voter: $seed_users[:sarah])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:accessibility], voter: $seed_users[:admin])

# Likes on analytics post (popular with product people)
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:analytics], voter: $seed_users[:alex])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:analytics], voter: $seed_users[:admin])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:analytics], voter: $seed_users[:maya])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:analytics], voter: $seed_users[:carlos])

# Likes on API post (highly requested by technical users)
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:api], voter: $seed_users[:sarah])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:api], voter: $seed_users[:maya])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:api], voter: $seed_users[:david])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:api], voter: $seed_users[:carlos])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:api], voter: $seed_users[:admin])

# Likes on collaboration post
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:collaboration], voter: $seed_users[:alex])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:collaboration], voter: $seed_users[:maya])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:collaboration], voter: $seed_users[:david])

# Likes on performance bug post (developers care about this)
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:performance], voter: $seed_users[:carlos])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:performance], voter: $seed_users[:admin])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:performance], voter: $seed_users[:maya])

# Likes on customization post
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:customization], voter: $seed_users[:alex])
Like.find_or_create_by!(organization: $seed_organization, likeable: $seed_posts[:customization], voter: $seed_users[:sarah])

# Add likes to some comments too (finding by creator and post since ActionText body can't be queried directly)

# Like Maya's PWA suggestion comment on mobile post
pwa_comment = Comment.find_by(post: $seed_posts[:mobile], creator: $seed_users[:maya])
if pwa_comment
  Like.find_or_create_by!(organization: $seed_organization, likeable: pwa_comment, voter: $seed_users[:alex])
  Like.find_or_create_by!(organization: $seed_organization, likeable: pwa_comment, voter: $seed_users[:carlos])
  Like.find_or_create_by!(organization: $seed_organization, likeable: pwa_comment, voter: $seed_users[:david])
end

# Like David's accessibility audit offer comment
audit_comment = Comment.find_by(post: $seed_posts[:accessibility], creator: $seed_users[:david])
if audit_comment
  Like.find_or_create_by!(organization: $seed_organization, likeable: audit_comment, voter: $seed_users[:maya])
  Like.find_or_create_by!(organization: $seed_organization, likeable: audit_comment, voter: $seed_users[:sarah])
  Like.find_or_create_by!(organization: $seed_organization, likeable: audit_comment, voter: $seed_users[:admin])
end

# Like Sarah's machine learning suggestion comment on analytics post
ml_comment = Comment.find_by(post: $seed_posts[:analytics], creator: $seed_users[:sarah])
if ml_comment
  Like.find_or_create_by!(organization: $seed_organization, likeable: ml_comment, voter: $seed_users[:alex])
  Like.find_or_create_by!(organization: $seed_organization, likeable: ml_comment, voter: $seed_users[:carlos])
end

# Like Maya's webhook suggestion comment on API post
webhook_comment = Comment.find_by(post: $seed_posts[:api], creator: $seed_users[:maya])
if webhook_comment
  Like.find_or_create_by!(organization: $seed_organization, likeable: webhook_comment, voter: $seed_users[:alex])
  Like.find_or_create_by!(organization: $seed_organization, likeable: webhook_comment, voter: $seed_users[:sarah])
  Like.find_or_create_by!(organization: $seed_organization, likeable: webhook_comment, voter: $seed_users[:admin])
end

puts "✅ Created comments and likes for engaging discussions"
