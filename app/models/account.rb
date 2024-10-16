# frozen_string_literal: true

class Account < ApplicationRecord
  include Billable
  include Domainable
  include Transferable

  belongs_to :owner, class_name: "User"
  has_many :account_invitations, dependent: :destroy
  has_many :account_users, dependent: :destroy
  has_many :users, through: :account_users
  has_many :addresses, as: :addressable, dependent: :destroy

  has_one_attached :logo

  validates :logo, resizable_image: true, max_file_size: 2.megabytes
  validates :name, presence: true

  scope :sorted, -> { order(name: :asc) }

  def owner?(user)
    owner_id == user.id
  end
end
