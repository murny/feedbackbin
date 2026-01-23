# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Prevent seed data from running in production
unless Rails.env.development?
  puts "⚠️ WARN: Seeding is just for development!"
else
  # Seed DSL
  def seed_account(name)
    print "  #{name}…"
    elapsed = Benchmark.realtime { require_relative "seeds/#{name}" }
    puts " #{elapsed.round(2)} sec"
  end

  def create_tenant(account_name)
    tenant_id = ActiveRecord::FixtureSet.identify(account_name)
    email_address = "shane@example.com"
    identity = Identity.find_or_create_by!(email_address: email_address, staff: true) do |new_identity|
      new_identity.email_verified_at = Time.current
    end

    unless account = Account.find_by(external_account_id: tenant_id)
      account = Account.create_with_owner(
        account: {
          external_account_id: tenant_id,
          name: account_name
        },
        owner: {
          name: "Shane Murnaghan",
          identity: identity
        }
      )
    end
    Current.account = account
  end

  def find_or_create_user(full_name, email_address)
    identity = Identity.find_or_create_by!(email_address: email_address)
    identity.update!(email_verified_at: Time.current) if identity.email_verified_at.nil?

    if user = identity.users.find_by(account: Current.account)
      user
    else
      identity.users.create!(name: full_name, account: Current.account)
    end
  end

  def login_as(user)
    Current.session = user.identity.sessions.create
  end

  def create_board(name, color: "#6366f1", creator: Current.user)
    Board.find_or_create_by!(name:) do |board|
      board.color = color
      board.creator = creator
    end
  end

  def create_idea(title, board:, description: nil, creator: Current.user)
    board.ideas.create!(title:, description:, creator:)
  end

  def create_comment(idea, body, creator: Current.user)
    idea.comments.create!(body:, creator:)
  end

  def create_reply(comment, body, creator: Current.user)
    comment.replies.create!(body:, idea: comment.idea, creator:)
  end

  def upvote(voteable, voter: Current.user)
    voteable.votes.find_or_create_by!(voter:)
  end

  def create_status(name, color:, position:, show_on_idea: true, show_on_roadmap: true)
    Status.find_or_create_by!(name:) do |status|
      status.color = color
      status.position = position
      status.show_on_idea = show_on_idea
      status.show_on_roadmap = show_on_roadmap
    end
  end

  def seed_default_statuses
    create_status("Planned", color: "#8b5cf6", position: 1, show_on_idea: true, show_on_roadmap: true)
    create_status("In Progress", color: "#f59e0b", position: 2, show_on_idea: true, show_on_roadmap: true)
    create_status("Complete", color: "#10b981", position: 3, show_on_idea: false, show_on_roadmap: true)
    create_status("Closed", color: "#ef4444", position: 4, show_on_idea: false, show_on_roadmap: false)
  end

  puts "🌱 Seeding accounts..."

  seed_account("feedbackbin")
  seed_account("cleanstate")

  puts "✅ Seeding complete!"
end
