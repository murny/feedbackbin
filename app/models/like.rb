# frozen_string_literal: true

class Like < ApplicationRecord
  belongs_to :voter, class_name: "User", default: -> { Current.user }
  belongs_to :likeable, polymorphic: true, counter_cache: true, touch: true
end
