# frozen_string_literal: true

class User < ApplicationRecord
  include Transferable
  include Role
  include Mentionable

  has_many :sessions, dependent: :destroy

  has_one_attached :avatar
  has_secure_password validations: false

  scope :active, -> { where(active: true) }
  scope :filtered_by, ->(query) { where("name like ?", "%#{query}%") }
  scope :ordered, -> { order(:name) }

  def initials
    name.scan(/\b\w/).join
  end

  def title
    [name, bio].compact_blank.join(" – ")
  end

  def deactivate
    transaction do
      close_remote_connections

      sessions.delete_all

      update! active: false, email_address: deactived_email_address
    end
  end

  def deactivated?
    !active?
  end

  private

  def deactived_email_address
    email_address.gsub(/@/, "-deactivated-#{SecureRandom.uuid}@")
  end

  def close_remote_connections
    ActionCable.server.remote_connections.where(current_user: self).disconnect reconnect: false
  end
end
