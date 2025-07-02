# frozen_string_literal: true

class Tag < ApplicationRecord
  belongs_to :organization, default: -> { Current.organization }
  has_many :post_tags, dependent: :destroy
  has_many :posts, through: :post_tags, counter_cache: :posts_count

  validates :name, presence: true, uniqueness: { scope: :organization_id }
  validates :name, format: { with: /\A[a-z0-9\-_]+\z/, message: "can only contain lowercase letters, numbers, hyphens, and underscores" }
  validates :color, presence: true, format: { with: /\A#[0-9a-f]{6}\z/i }
  
  scope :popular, -> { order(posts_count: :desc) }
  scope :alphabetical, -> { order(:name) }

  before_validation :normalize_name

  def to_param
    name
  end

  private

    def normalize_name
      self.name = name&.downcase&.strip&.gsub(/[^a-z0-9\-_]/, '-')&.gsub(/-+/, '-')&.gsub(/\A-|-\z/, '')
    end
end