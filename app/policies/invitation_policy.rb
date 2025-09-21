# frozen_string_literal: true

class InvitationPolicy < ApplicationPolicy
  def new?
    admin?
  end

  def create?
    new?
  end
end
