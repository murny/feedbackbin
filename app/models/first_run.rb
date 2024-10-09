# frozen_string_literal: true

class FirstRun
  ACCOUNT_NAME = "FeedbackBin"
  FIRST_BOARD_NAME = "Feature Requests"

  def self.create!(user_params)
    Account.create!(name: ACCOUNT_NAME)
    Board.create!(name: FIRST_BOARD_NAME)
    User.create!(user_params.merge(role: :administrator))
  end
end
