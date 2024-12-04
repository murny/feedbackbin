# frozen_string_literal: true

class MembershipPolicy < ApplicationPolicy
  def index?
    membership.present?
  end

  def edit?
    admin?
  end

  def update?
    edit?
  end

  def destroy?
    owned? || admin?
  end

  private

  def owned?
    record && membership && record.user_id == membership.user_id
  end
end
