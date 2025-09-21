# frozen_string_literal: true

class Organization < ApplicationRecord
  include Domainable
  include Searchable
  include Transferable

  has_one_attached :logo

  validates :logo, resizable_image: true, max_file_size: 2.megabytes
  validates :name, presence: true
end
