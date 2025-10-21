# frozen_string_literal: true

class Organization < ApplicationRecord
  include Domainable
  include Searchable

  has_one_attached :logo

  belongs_to :default_post_status, class_name: "PostStatus"
  belongs_to :owner, class_name: "User"

  validates :logo, resizable_image: true, max_file_size: 2.megabytes
  validates :name, presence: true
  validate :owner_must_be_administrator

  # Check if user is the owner
  def owned_by?(user)
    owner == user
  end

  private

    def owner_must_be_administrator
      if owner && !owner.administrator?
        errors.add(:owner, "must be an administrator")
      end
    end
end
