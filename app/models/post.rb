# frozen_string_literal: true

class Post < ApplicationRecord
  include ModelSortable
  include Likeable

  has_rich_text :body

  belongs_to :author, class_name: "User", default: -> { Current.user }
  belongs_to :category
  belongs_to :post_status, optional: true
  belongs_to :organization, default: -> { Current.organization }

  has_many :comments, dependent: :destroy
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags

  broadcasts_refreshes

  validates :title, presence: true

  scope :pinned, -> { where(pinned: true) }
  scope :unpinned, -> { where(pinned: false) }
  scope :by_category, ->(category) { where(category: category) }
  scope :with_tag, ->(tag) { joins(:tags).where(tags: { name: tag }) }
  scope :popular, -> { order(views_count: :desc) }

  before_create :initialize_views_count

  def pin!
    update!(pinned: true)
  end

  def unpin!
    update!(pinned: false)
  end

  def increment_view_count!
    increment!(:views_count)
  end

  def tag_names
    tags.pluck(:name)
  end

  def tag_names=(names)
    tag_objects = names.reject(&:blank?).map do |name|
      Tag.find_or_create_by(
        name: name.downcase.strip, 
        organization: organization
      ) do |tag|
        tag.color = generate_tag_color
      end
    end
    self.tags = tag_objects
  end

  def status_indicator_color
    return status_color if status_color.present?
    return post_status&.color if post_status&.color.present?
    
    case
    when pinned? then "#3b82f6"  # blue
    when created_at > 1.day.ago then "#10b981"  # green for new posts
    else nil
    end
  end

  private

    def initialize_views_count
      self.views_count ||= 0
    end

    def generate_tag_color
      colors = %w[#3b82f6 #10b981 #f59e0b #ef4444 #8b5cf6 #06b6d4 #84cc16 #f97316]
      colors.sample
    end
end
