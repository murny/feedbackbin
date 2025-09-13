# frozen_string_literal: true

class Organization < SharedApplicationRecord
  include Domainable
  include Searchable
  include Transferable

  belongs_to :owner, class_name: "User"

  has_many :organization_invitations, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  has_one_attached :logo

  # accepts_nested_attributes_for :categories, reject_if: :all_blank

  validates :logo, resizable_image: true, max_file_size: 2.megabytes
  validates :name, presence: true
  # validate :must_have_at_least_one_category, on: :create

  scope :sorted, -> { order(name: :asc) }

  before_create do
    memberships.new(user: owner, role: Membership.roles[:administrator])
  end

  after_create :create_tenant_database

  def owner?(user)
    owner_id == user&.id
  end

  private

    def create_tenant_database
      ApplicationRecord.create_tenant(subdomain)
    end

  # def must_have_at_least_one_category
  #   errors.add(:categories, :must_have_at_least_one) if categories.empty?
  # end
end
