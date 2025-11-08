# frozen_string_literal: true

class Organization < ApplicationRecord
  include Domainable
  include Searchable

  has_one_attached :logo

  belongs_to :default_post_status, class_name: "PostStatus"
  belongs_to :owner, class_name: "User"

  # Enums
  enum :theme, {
    system: "system",
    light: "light",
    dark: "dark",
    purple: "purple",
    navy: "navy"
  }, default: :system

  validates :logo, resizable_image: true, max_file_size: 2.megabytes
  validates :name, presence: true
  validates :accent_color, format: { with: /\A#[0-9a-f]{6}\z/i, allow_blank: true }
  validates :theme, presence: true
  validate :owner_must_be_administrator

  # Check if user is the owner
  def owned_by?(user)
    owner == user
  end

  # Theme-related methods
  def accent_color_or_default
    accent_color.presence || default_accent_color_for_theme
  end

  def default_accent_color_for_theme
    case theme
    when "light", "dark", "system"
      "#3b82f6" # Tailwind blue-500
    when "purple"
      "#a855f7" # Tailwind purple-500
    when "navy"
      "#3b82f6" # Tailwind blue-500
    else
      "#3b82f6"
    end
  end

  def effective_theme_for_user(user)
    if allow_user_theme_choice? && user&.theme_preference.present? && user.theme_preference != "organization"
      user.theme_preference
    else
      theme
    end
  end

  private

    def owner_must_be_administrator
      if owner && !owner.administrator?
        errors.add(:owner, :must_be_administrator)
      end
    end
end
