# frozen_string_literal: true

class Organization < ApplicationRecord
  include Domainable
  include Searchable

  has_one_attached :logo

  belongs_to :default_post_status, class_name: "PostStatus"
  belongs_to :owner, class_name: "User"

  # Enums
  enum :root_path_module, {
    posts: "posts",
    roadmap: "roadmap",
    changelog: "changelog"
  }, default: :posts

  # Validations
  validates :logo, resizable_image: true, max_file_size: 2.megabytes
  validates :name, presence: true
  validate :owner_must_be_administrator
  validate :at_least_one_module_enabled
  validate :root_path_module_is_enabled

  # Scopes
  scope :with_posts_enabled, -> { where(posts_enabled: true) }
  scope :with_roadmap_enabled, -> { where(roadmap_enabled: true) }
  scope :with_changelog_enabled, -> { where(changelog_enabled: true) }

  # Check if user is the owner
  def owned_by?(user)
    owner == user
  end

  # Module management methods
  def enabled_modules
    modules = []
    modules << :posts if posts_enabled?
    modules << :roadmap if roadmap_enabled?
    modules << :changelog if changelog_enabled?
    modules
  end

  def module_enabled?(module_name)
    case module_name.to_sym
    when :posts
      posts_enabled?
    when :roadmap
      roadmap_enabled?
    when :changelog
      changelog_enabled?
    else
      false
    end
  end

  def root_path_url
    case root_path_module
    when "posts"
      Rails.application.routes.url_helpers.posts_path
    when "roadmap"
      Rails.application.routes.url_helpers.roadmap_path
    when "changelog"
      Rails.application.routes.url_helpers.changelogs_path
    else
      Rails.application.routes.url_helpers.root_path
    end
  end

  private

    def owner_must_be_administrator
      if owner && !owner.administrator?
        errors.add(:owner, :must_be_administrator)
      end
    end

    def at_least_one_module_enabled
      unless posts_enabled? || roadmap_enabled? || changelog_enabled?
        errors.add(:base, :at_least_one_module_required)
      end
    end

    def root_path_module_is_enabled
      return unless root_path_module.present?

      unless module_enabled?(root_path_module)
        errors.add(:root_path_module, :must_be_enabled)
      end
    end
end
