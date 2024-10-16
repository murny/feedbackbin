# frozen_string_literal: true

class FirstRun
  ACCOUNT_NAME = "FeedbackBin"
  FIRST_BOARD_NAME = "Feature Requests"

  def self.create!(user_params)
    user = User.create!(user_params)
    account = Account.create!(name: ACCOUNT_NAME, owner: user)
    account.account_users.create(user: user, role: :administrator)
    Board.create!(name: FIRST_BOARD_NAME)
    account
  end
end
