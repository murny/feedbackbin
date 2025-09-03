# frozen_string_literal: true

class FirstRun
  ORGANIZATION_DEFAULT_NAME = "FeedbackBin"
  FIRST_CATEGORY_NAME = "Feature Requests"

  def self.create!(user_params)
    ApplicationRecord.transaction do
      user = User.create!(user_params)
      Organization.create!(
        name: ORGANIZATION_DEFAULT_NAME,
        owner: user,
        categories_attributes: [ { name: FIRST_CATEGORY_NAME } ]
      )
    end
  end
end
