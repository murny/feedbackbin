# frozen_string_literal: true

create_tenant "Acme Corp"
seed_default_statuses

alice = find_or_create_user "Alice Admin", "alice@acme.example.com"
bob = find_or_create_user "Bob Tester", "bob@acme.example.com"

login_as alice

create_board("Acme Feedback", color: "#6366f1").tap do |board|
  create_idea("Add an Acme dashboard",
    description: "Acme users want a dashboard view showing feedback submitted this week.",
    board: board,
    creator: alice).tap do |idea|
    upvote idea, voter: alice
    upvote idea, voter: bob
    create_comment(idea, "Would love this for the monthly review meeting.", creator: bob)
  end

  create_idea("Export feedback to CSV",
    description: "Admins need to export feedback data for offline reporting.",
    board: board,
    creator: bob).tap do |idea|
    upvote idea, voter: alice
  end
end

create_board("Acme Bugs", color: "#ef4444").tap do |board|
  create_idea("Dashboard chart misaligned on mobile",
    description: "The weekly stats chart is clipped on phones under 375px wide.",
    board: board,
    creator: bob)
end
