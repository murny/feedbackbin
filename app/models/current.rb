# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :user
end
