# frozen_string_literal: true

class Organization < ApplicationRecord
  include Domainable
  include Searchable

  has_one_attached :logo

  belongs_to :default_post_status, class_name: "PostStatus"

  validates :logo, resizable_image: true, max_file_size: 2.megabytes
  validates :name, presence: true
end
