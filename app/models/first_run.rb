# frozen_string_literal: true

class FirstRun
  ACCOUNT_NAME = "FeedbackBin"
  FIRST_CATEGORY_NAME = "Feature Requests"

  def self.create!(user_params)
    user = User.create!(user_params)
    account = Account.create!(name: ACCOUNT_NAME, owner: user)
    account.account_users.create(user: user, role: :administrator)
    account.categories.create!(name: FIRST_CATEGORY_NAME)
    account
  end
end
