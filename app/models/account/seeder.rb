# frozen_string_literal: true

class Account::Seeder
  attr_reader :account, :creator

  def initialize(account, creator)
    @account = account
    @creator = creator
  end

  def seed
    Current.set(user: creator, account: account) do
      create_statuses
      create_board_with_ideas
    end
  end

  private

    def create_statuses
      Status.create!([
        { name: "Planned", color: "#8b5cf6", position: 1, account: account },
        { name: "In Progress", color: "#f59e0b", position: 2, account: account },
        { name: "Complete", color: "#10b981", position: 3, account: account },
        { name: "Closed", color: "#ef4444", position: 4, account: account }
      ])
    end

    def create_board_with_ideas
      board = account.boards.create!(
        name: "Feature Ideas",
        color: "#3b82f6",
        creator: creator
      )

      create_welcome_idea(board)
      create_example_ideas_intro(board)
      create_status_tutorial_idea(board)
    end

    def create_welcome_idea(board)
      board.ideas.create!(
        creator: creator,
        title: "[Start here] Welcome to FeedbackBin",
        pinned: true,
        description: <<~HTML
          <p>Welcome to FeedbackBin, your new tool for collecting and managing customer feedback.</p>
          <p>We've created a few example ideas to help you get acquainted with the interface. Take a look around, click on some ideas, and explore the features.</p>
          <h3>Quick tips to get started:</h3>
          <ul>
            <li>Click on any idea to view its details and comments</li>
            <li>Use the status dropdown to move ideas through your workflow</li>
            <li>Invite your team from the account settings menu</li>
            <li>Share your public roadmap with customers</li>
          </ul>
          <p>If you have any questions, reach out to us anytime. We're here to help!</p>
          <p><strong>The FeedbackBin Team</strong></p>
        HTML
      )
    end

    def create_example_ideas_intro(board)
      board.ideas.create!(
        creator: creator,
        title: "[Read Me] We've created some example ideas for you",
        description: <<~HTML
          <p>You'll notice we've added a few example ideas to help you explore FeedbackBin.</p>
          <p>Feel free to:</p>
          <ul>
            <li>Change their status to see how ideas move through your roadmap</li>
            <li>Edit them to see how the editor works</li>
            <li>Add comments to try out the discussion feature</li>
            <li>Create your own ideas when you're ready</li>
          </ul>
          <p><strong>Delete these example ideas whenever you're done exploring.</strong></p>
        HTML
      )
    end

    def create_status_tutorial_idea(board)
      planned = account.statuses.find_by(name: "Planned")

      board.ideas.create!(
        creator: creator,
        title: "[Try it] Change the status of this idea",
        status: planned,
        description: <<~HTML
          <p>Statuses help you organize ideas and show progress on your public roadmap.</p>
          <p>This idea is currently marked as <strong>Planned</strong>. Try changing it:</p>
          <ol>
            <li>Look for the status dropdown at the top of the idea</li>
            <li>Click it and select a different status like "In Progress"</li>
            <li>Watch how the idea moves in your roadmap view</li>
          </ol>
          <p>Ideas without a status are set to <strong>Open</strong> by default. Perfect for collecting raw feedback before deciding what to build.</p>
        HTML
      )
    end
end
