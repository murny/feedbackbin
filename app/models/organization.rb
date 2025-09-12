# frozen_string_literal: true

class Organization < SharedApplicationRecord
  include Domainable
  include Searchable
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

  accepts_nested_attributes_for :categories, reject_if: :all_blank

  validates :logo, resizable_image: true, max_file_size: 2.megabytes
  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true
  validate :must_have_at_least_one_category, on: :create

  scope :sorted, -> { order(name: :asc) }

  before_validation :ensure_subdomain, on: :create
  before_create do
    memberships.new(user: owner, role: Membership.roles[:administrator])
  end
  after_create :create_tenant_database

  def owner?(user)
    owner_id == user&.id
  end
  
  def tenant_name
    subdomain
  end

  private

    def ensure_subdomain
      self.subdomain ||= name.parameterize if name.present?
    end

    def create_tenant_database
      ApplicationRecord.create_tenant(subdomain) unless ApplicationRecord.tenant_exist?(subdomain)
      
      # Run tenant migrations
      ApplicationRecord.with_tenant(subdomain) do
        Rails.application.load_tasks
        Rake::Task['db:migrate'].invoke
      end
    end

    def must_have_at_least_one_category
      errors.add(:categories, :must_have_at_least_one) if categories.empty?
    end
end
