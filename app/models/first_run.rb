# frozen_string_literal: true

class FirstRun
  ORGANIZATION_DEFAULT_NAME = "FeedbackBin"
  FIRST_CATEGORY_NAME = "Feature Requests"

  def self.create!(user_params)
    user = User.create!(user_params)
    organization = Organization.create!(name: ORGANIZATION_DEFAULT_NAME, owner: user)
    organization.memberships.create(user: user, role: :administrator)
    organization.categories.create!(name: FIRST_CATEGORY_NAME)
    organization
  end
end
