# frozen_string_literal: true

module User::Role
  extend ActiveSupport::Concern

  included do
    enum :role, {member: 0, administrator: 1}, default: :member, validate: true
  end

  def can_administer?
    administrator?
  end
end
