# frozen_string_literal: true

class Vote < ApplicationRecord
  belongs_to :voter, class_name: "User", default: -> { Current.user }
  belongs_to :voteable, polymorphic: true, counter_cache: true, touch: true

  validates :voter_id, uniqueness: { scope: %i[voteable_type voteable_id] }
end
