module User::Role
  extend ActiveSupport::Concern

  included do
    enum :role, %i[ member administrator ], default: :member
  end

  def can_administer?
    administrator?
  end
end
