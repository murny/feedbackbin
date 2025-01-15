# frozen_string_literal: true

class Organization < ApplicationRecord
  include Domainable
  include Transferable

  belongs_to :owner, class_name: "User"

  has_many :organization_invitations, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :changelogs, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :post_statuses, dependent: :destroy
  has_many :users, through: :memberships

  has_one_attached :logo

  validates :logo, resizable_image: true, max_file_size: 2.megabytes
  validates :name, presence: true

  scope :sorted, -> { order(name: :asc) }

  def owner?(user)
    owner_id == user&.id
  end
end
