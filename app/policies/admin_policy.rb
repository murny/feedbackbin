# frozen_string_literal: true

class AdminPolicy < ApplicationPolicy
  def access?
    admin?
  end
end
