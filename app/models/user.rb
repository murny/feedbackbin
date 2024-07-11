class User < ApplicationRecord
  include Role, Transferable

  has_many :sessions, dependent: :destroy
  has_secure_password validations: false

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }

  def current?
    self == Current.user
  end

  def deactivate
    transaction do
      sessions.delete_all
      update! active: false, email_address: deactived_email_address
    end
  end

  private
    def deactived_email_address
      email_address&.gsub(/@/, "-deactivated-#{SecureRandom.uuid}@")
    end
end
