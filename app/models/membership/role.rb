# frozen_string_literal: true

class Membership
  module Role
    extend ActiveSupport::Concern

    included do
      enum :role, { member: 0, administrator: 1 }, default: :member, validate: true
    end
  end
end
