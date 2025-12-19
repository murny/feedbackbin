# frozen_string_literal: true

create_tenant "FeedbackBin"
seed_default_statuses

shane = find_or_create_user "Shane Murnaghan", "shane@example.com"
jane = find_or_create_user "Jane Doe", "jane@example.com"
john = find_or_create_user "John Smith", "john@example.com"
eric = find_or_create_user "Eric Johnson", "eric@example.com"

login_as shane

create_board("Feature Requests", color: "#6366f1").tap do |board|
  # Dark mode idea with comments, replies, and votes
  dark_mode = create_idea("Add dark mode support",
    description: "I would love to see dark mode on this site. It's easier on the eyes when working late at night and helps reduce eye strain. Many modern apps support this feature now.",
    board: board)

  upvote dark_mode, voter: shane
  upvote dark_mode, voter: jane
  upvote dark_mode, voter: john
  upvote dark_mode, voter: eric

  comment1 = create_comment(dark_mode, "This would be amazing! I work late nights and the bright theme is really harsh on my eyes.", creator: jane)
  upvote comment1, voter: shane
  upvote comment1, voter: john

  create_reply(comment1, "Agreed! Would also be great if it could sync with the OS dark mode setting automatically.", creator: john)

  comment2 = create_comment(dark_mode, "Any timeline on when this might be implemented? It's a highly requested feature.", creator: eric)
  create_reply(comment2, "We're looking into this for our next release cycle. Stay tuned!", creator: shane)

  # Mobile app idea
  mobile_app = create_idea("Mobile app support",
    description: "As a UX designer, I'd love to see a dedicated mobile app. The responsive web version is good, but a native app would provide better user engagement and push notifications for important updates.",
    board: board)

  upvote mobile_app, voter: jane
  upvote mobile_app, voter: eric

  create_comment(mobile_app, "Push notifications would be a game changer for staying on top of customer feedback.", creator: jane)

  # API access idea
  api_idea = create_idea("Public API access",
    description: "It would be great to have a public API so we can integrate feedback data into our internal dashboards and reporting tools.",
    board: board)

  upvote api_idea, voter: john
  upvote api_idea, voter: eric
  upvote api_idea, voter: shane

  api_comment = create_comment(api_idea, "We'd use this to sync feedback with our Jira board automatically.", creator: john)
  upvote api_comment, voter: eric
  create_reply(api_comment, "Same here! Integration with project management tools would save us hours every week.", creator: eric)
end

create_board("Bug Reports", color: "#ef4444").tap do |board|
  # Bug report with discussion
  bug = create_idea("Search not returning all results",
    description: "When I search for ideas containing certain keywords, some results that should appear are missing. I've noticed this happens especially with older ideas.",
    board: board,
    creator: jane)

  upvote bug, voter: john

  bug_comment = create_comment(bug, "I've experienced this too. It seems like ideas from more than 30 days ago don't show up.", creator: john)
  create_reply(bug_comment, "Thanks for the additional detail. We'll investigate the search indexing for older records.", creator: shane)

  create_comment(bug, "Is there a workaround in the meantime?", creator: eric)
end

create_board("General Discussion", color: "#22c55e").tap do |board|
  create_idea("Welcome to FeedbackBin!",
    description: "This is a space for collecting and discussing product feedback. Feel free to submit ideas, vote on features you'd like to see, and join the conversation!",
    board: board)
end
