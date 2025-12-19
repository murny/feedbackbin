# frozen_string_literal: true

create_tenant "FeedbackBin"
seed_default_statuses

shane = find_or_create_user "Shane Murnaghan", "shane@example.com"
jane = find_or_create_user "Jane Doe", "jane@example.com"
john = find_or_create_user "John Smith", "john@example.com"
eric = find_or_create_user "Eric Johnson", "eric@example.com"

login_as shane

create_board("Feature Requests", color: "#6366f1").tap do |board|
  create_idea("Add dark mode support",
    description: "I would love to see dark mode on this site. It's easier on the eyes when working late at night and helps reduce eye strain. Many modern apps support this feature now.",
    board: board).tap do |idea|
    upvote idea, voter: shane
    upvote idea, voter: jane
    upvote idea, voter: john
    upvote idea, voter: eric

    create_comment(idea, "This would be amazing! I work late nights and the bright theme is really harsh on my eyes.", creator: jane).tap do |comment|
      upvote comment, voter: shane
      upvote comment, voter: john
      create_reply(comment, "Agreed! Would also be great if it could sync with the OS dark mode setting automatically.", creator: john)
    end

    create_comment(idea, "Any timeline on when this might be implemented? It's a highly requested feature.", creator: eric).tap do |comment|
      create_reply(comment, "We're looking into this for our next release cycle. Stay tuned!", creator: shane)
    end
  end

  create_idea("Mobile app support",
    description: "As a UX designer, I'd love to see a dedicated mobile app. The responsive web version is good, but a native app would provide better user engagement and push notifications for important updates.",
    board: board).tap do |idea|
    upvote idea, voter: jane
    upvote idea, voter: eric

    create_comment(idea, "Push notifications would be a game changer for staying on top of customer feedback.", creator: jane)
  end

  create_idea("Public API access",
    description: "It would be great to have a public API so we can integrate feedback data into our internal dashboards and reporting tools.",
    board: board).tap do |idea|
    upvote idea, voter: john
    upvote idea, voter: eric
    upvote idea, voter: shane

    create_comment(idea, "We'd use this to sync feedback with our Jira board automatically.", creator: john).tap do |comment|
      upvote comment, voter: eric
      create_reply(comment, "Same here! Integration with project management tools would save us hours every week.", creator: eric)
    end
  end
end

create_board("Bug Reports", color: "#ef4444").tap do |board|
  create_idea("Search not returning all results",
    description: "When I search for ideas containing certain keywords, some results that should appear are missing. I've noticed this happens especially with older ideas.",
    board: board,
    creator: jane).tap do |idea|
    upvote idea, voter: john

    create_comment(idea, "I've experienced this too. It seems like ideas from more than 30 days ago don't show up.", creator: john).tap do |comment|
      create_reply(comment, "Thanks for the additional detail. We'll investigate the search indexing for older records.", creator: shane)
    end

    create_comment(idea, "Is there a workaround in the meantime?", creator: eric)
  end
end

create_board("General Discussion", color: "#22c55e").tap do |board|
  create_idea("Welcome to FeedbackBin!",
    description: "This is a space for collecting and discussing product feedback. Feel free to submit ideas, vote on features you'd like to see, and join the conversation!",
    board: board)
end
