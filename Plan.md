# Multi-Tenancy Migration Plan: ActiveRecord Tenanted

## Executive Summary

This plan outlines the migration from a single-database multi-tenancy model (using `organization_id` foreign keys) to separate SQLite databases per tenant using the `activerecord-tenanted` gem. This approach provides stronger data isolation, better performance scalability, and simplified subdomain/custom domain support.

## Current State Analysis

### Existing Multi-Tenancy Structure
- **Tenant Model**: `Organization` serves as the tenant boundary
- **Current Approach**: Single database with `organization_id` foreign keys on all tenanted models
- **Tenanted Models**: Categories, Changelogs, Comments, Likes, Posts, PostStatuses, OrganizationInvitations
- **Shared Models**: Users, Sessions, UserConnectedAccounts, Memberships (bridge table)
- **Database**: Single SQLite database with multiple auxiliary databases (cache, queue, cable)

### Uncommitted Changes Detected
- ✅ Added `activerecord-tenanted` gem to Gemfile
- ✅ Created `SharedApplicationRecord` for shared models
- ✅ Added `tenanted` to `ApplicationRecord`
- ✅ Moved User and Organization to `SharedApplicationRecord`
- ✅ Updated Membership to use `SharedApplicationRecord`

## Architecture Decision: Shared Users vs Tenant Users

### Recommended Approach: Shared Users with Tenant-Isolated Data

**Pros:**
- Users can belong to multiple organizations with single login
- Simpler user management and authentication
- Easier cross-tenant features (user invitations, transfers)
- Maintains existing user experience
- Reduces data duplication

**Cons:**
- Mixed architecture (some shared, some tenanted)
- More complex queries for user-related data
- Potential security considerations with shared user data

### Alternative Approach: Fully Isolated Tenants

**Pros:**
- Complete data isolation per tenant
- Simpler tenant-scoped queries
- Better for compliance/regulatory requirements
- No cross-tenant data leakage risk

**Cons:**
- Users need separate accounts per organization
- Complex user transfers between tenants
- More storage overhead
- Breaks existing user workflows

## Migration Plan

### Phase 1: Database Configuration & Infrastructure

#### 1.1 Update Database Configuration

**File: `config/database.yml`**
```yaml
default: &default
  adapter: sqlite3
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 10 } %>
  timeout: 5000

primary: &primary
  <<: *default
  database: storage/<%= Rails.env %>.sqlite3

# Shared database for users, organizations, memberships
shared: &shared
  <<: *default
  database: storage/<%= Rails.env %>_shared.sqlite3
  migrations_paths: db/shared_migrate

# Tenanted databases - dynamic per organization
tenant: &tenant
  <<: *default
  database: storage/<%= Rails.env %>/%{tenant}/main.sqlite3
  migrations_paths: db/tenant_migrate
  tenanted: true

cache: &cache
  <<: *default
  database: storage/<%= Rails.env %>_cache.sqlite3
  migrations_paths: db/cache_migrate

queue: &queue
  <<: *default
  database: storage/<%= Rails.env %>_queue.sqlite3
  migrations_paths: db/queue_migrate

cable: &cable
  <<: *default
  database: storage/<%= Rails.env %>_cable.sqlite3
  migrations_paths: db/cable_migrate

development:
  primary: *tenant  # Primary connection becomes tenant-scoped
  shared: *shared   # New shared connection
  cable: *cable
  cache: *cache
  queue: *queue

test:
  primary: *tenant
  shared: *shared
  cable: *cable
  cache: *cache
  queue: *queue

production:
  primary: *tenant
  shared: *shared
  cable: *cable
  cache: *cache
  queue: *queue
```

#### 1.2 Create Migration Directories
```bash
mkdir -p db/shared_migrate db/tenant_migrate
```

#### 1.3 Update Application Configuration

**File: `config/application.rb`**
```ruby
# Add after class Application < Rails::Application
config.active_record.multiple_databases = true

# Configure tenanted databases
config.active_record.tenanted = {
  tenant_resolver: ->(request) {
    # Extract subdomain-based tenant resolution
    subdomain = request.subdomain
    return nil if subdomain.blank? || subdomain == 'www'
    
    # Check if organization exists with this subdomain
    Organization.find_by(subdomain: subdomain)&.subdomain
  },
  tenant_class: ApplicationRecord
}
```

### Phase 2: Model Restructuring

#### 2.1 Finalize Application Record Structure

**File: `app/models/application_record.rb`**
```ruby
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  
  tenanted
  
  connects_to database: { writing: :primary }
end
```

**File: `app/models/shared_application_record.rb`**
```ruby
class SharedApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  
  connects_to database: { writing: :shared }
end
```

#### 2.2 Update Model Inheritance

**Shared Models (remain in SharedApplicationRecord):**
- ✅ User
- ✅ Organization  
- ✅ Membership
- ✅ Session
- ✅ UserConnectedAccount
- ✅ OrganizationInvitation

**Tenanted Models (move to ApplicationRecord):**
- Category
- Changelog
- Comment
- Like
- Post
- PostStatus

#### 2.3 Remove organization_id from Tenanted Models

**Migration Strategy:**
```ruby
# Example for posts table
class RemoveOrganizationIdFromPosts < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :posts, :organizations
    remove_index :posts, :organization_id
    remove_column :posts, :organization_id, :bigint
  end
end
```

**Models to Update:**
- `app/models/category.rb`
- `app/models/changelog.rb`
- `app/models/comment.rb`
- `app/models/like.rb`
- `app/models/post.rb`
- `app/models/post_status.rb`

#### 2.4 Update Model Associations

**Example: `app/models/post.rb`**
```ruby
class Post < ApplicationRecord
  include ModelSortable
  include Likeable
  include Searchable

  has_rich_text :body

  # Remove organization association - now implicit via tenant
  belongs_to :author, class_name: "User", default: -> { Current.user }
  belongs_to :category
  belongs_to :post_status, optional: true

  has_many :comments, dependent: :destroy

  broadcasts_refreshes

  validates :title, presence: true

  scope :ordered_with_pinned, -> { order(pinned: :desc, created_at: :desc) }
end
```

### Phase 3: Cross-Database Associations

#### 3.1 Handle User-Tenant Relationships

**File: `app/models/concerns/cross_tenant_associations.rb`**
```ruby
module CrossTenantAssociations
  extend ActiveSupport::Concern

  def user
    @user ||= User.find(user_id) if user_id.present?
  end

  def user=(user)
    @user = user
    self.user_id = user&.id
  end
end
```

#### 3.2 Update Models with Cross-Database References

**Models requiring user lookups:**
- Post (`author_id` → User)
- Comment (`creator_id` → User)  
- Like (`voter_id` → User)

### Phase 4: Middleware & Routing

#### 4.1 Install Tenant Selector Middleware

**File: `config/application.rb`**
```ruby
# Add to middleware stack
config.middleware.insert_before ActionDispatch::Session::CookieStore, 
  ActiveRecord::Tenanted::TenantSelector
```

#### 4.2 Update Organization Model

**File: `app/models/organization.rb`**
```ruby
class Organization < SharedApplicationRecord
  include Domainable
  include Searchable
  include Transferable

  belongs_to :owner, class_name: "User"
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  # Ensure subdomain is present for tenant resolution
  validates :subdomain, presence: true, uniqueness: true
  validates :name, presence: true

  before_create :ensure_subdomain
  after_create :create_tenant_database

  def tenant_name
    subdomain
  end

  private

  def ensure_subdomain
    self.subdomain ||= name.parameterize if name.present?
  end

  def create_tenant_database
    ApplicationRecord.create_tenant(subdomain)
    
    # Run tenant migrations
    ApplicationRecord.with_tenant(subdomain) do
      Rails.application.load_tasks
      Rake::Task['db:migrate'].invoke
    end
  end
end
```

#### 4.3 Subdomain Routing

**File: `config/routes.rb`**
```ruby
Rails.application.routes.draw do
  # Subdomain-based routing
  constraints subdomain: /.+/ do
    # All existing routes remain the same
    # Tenant context handled by middleware
    root "posts#index"
    # ... rest of routes
  end

  # Root domain routes for registration, login
  constraints subdomain: ['', 'www'] do
    get 'login', to: 'sessions#new'
    post 'login', to: 'sessions#create'
    # ... auth routes
  end
end
```

### Phase 5: Data Migration Strategy

#### 5.1 Create Tenant Databases

**Migration Script: `lib/tasks/tenancy.rake`**
```ruby
namespace :tenancy do
  desc "Migrate existing data to tenant databases"
  task migrate_data: :environment do
    Organization.find_each do |org|
      puts "Migrating data for organization: #{org.name} (#{org.subdomain})"
      
      # Create tenant database if it doesn't exist
      ApplicationRecord.create_tenant(org.subdomain) unless ApplicationRecord.tenant_exist?(org.subdomain)
      
      ApplicationRecord.with_tenant(org.subdomain) do
        # Migrate categories
        org.categories.find_each do |category|
          Category.create!(
            name: category.name,
            description: category.description,
            created_at: category.created_at,
            updated_at: category.updated_at
          )
        end

        # Migrate posts
        org.posts.find_each do |post|
          Post.create!(
            title: post.title,
            author_id: post.author_id,
            category_id: post.category_id,
            post_status_id: post.post_status_id,
            pinned: post.pinned,
            comments_count: post.comments_count,
            likes_count: post.likes_count,
            created_at: post.created_at,
            updated_at: post.updated_at
          )
          
          # Copy ActionText content
          if post.body.present?
            new_post = Post.find_by(title: post.title, author_id: post.author_id)
            new_post.body = post.body.body
            new_post.save!
          end
        end

        # Migrate comments, likes, changelogs, post_statuses...
        # Similar pattern for each model
      end
      
      puts "✓ Completed migration for #{org.name}"
    end
  end

  desc "Verify tenant data integrity"
  task verify_data: :environment do
    # Verification logic
  end
end
```

#### 5.2 Tenant Database Schema

**Generate tenant migrations:**
```bash
# Create separate migrations for tenant-only tables
bin/rails generate migration CreateTenantCategories --database=tenant
bin/rails generate migration CreateTenantPosts --database=tenant
bin/rails generate migration CreateTenantComments --database=tenant
bin/rails generate migration CreateTenantLikes --database=tenant
bin/rails generate migration CreateTenantChangelogs --database=tenant
bin/rails generate migration CreateTenantPostStatuses --database=tenant
```

### Phase 6: Controller & Service Updates

#### 6.1 Update Authentication Flow

**File: `app/controllers/concerns/authentication.rb`**
```ruby
module Authentication
  private

  def authenticate
    if (user_id = session[:user_id])
      Current.user = User.find(user_id)
    else
      redirect_to login_url
    end
  end

  def ensure_organization_access
    return if Current.user.blank?
    return if Current.organization.blank?

    unless Current.user.memberships.joins(:organization)
                     .where(organization: { subdomain: ActiveRecord::Tenanted.current_tenant })
                     .exists?
      redirect_to unauthorized_path
    end
  end
end
```

#### 6.2 Update Current Context

**File: `app/models/current.rb`**
```ruby
class Current < ActiveSupport::CurrentAttributes
  attribute :user
  
  def organization
    return nil if ActiveRecord::Tenanted.current_tenant.blank?
    @organization ||= Organization.find_by(subdomain: ActiveRecord::Tenanted.current_tenant)
  end
  
  def organization_id
    organization&.id
  end
end
```

### Phase 7: Testing & Deployment

#### 7.1 Update Test Configuration

**File: `test/test_helper.rb`**
```ruby
# Add tenant test setup
def with_tenant(tenant_name)
  ApplicationRecord.with_tenant(tenant_name) do
    yield
  end
end

# Setup test tenants
class ActiveSupport::TestCase
  setup do
    # Create test tenant for each organization fixture
    Organization.all.each do |org|
      ApplicationRecord.create_tenant(org.subdomain) unless ApplicationRecord.tenant_exist?(org.subdomain)
    end
  end
  
  teardown do
    # Clean up test tenants if needed
  end
end
```

#### 7.2 Update Fixtures

**Move tenant-specific fixtures:**
- `test/fixtures/categories.yml` → `test/tenant_fixtures/categories.yml`
- `test/fixtures/posts.yml` → `test/tenant_fixtures/posts.yml`
- etc.

### Phase 8: Deployment Considerations

#### 8.1 Migration Deployment Strategy

1. **Pre-deployment:**
   - Backup existing database
   - Test migration script on copy of production data
   - Prepare rollback plan

2. **Deployment:**
   - Deploy code with feature flag disabled
   - Run data migration script
   - Verify data integrity
   - Enable tenant routing gradually

3. **Post-deployment:**
   - Monitor performance and errors
   - Clean up old organization_id columns after verification
   - Update monitoring/logging for multi-tenant context

#### 8.2 Performance Considerations

- **Database Connection Pooling**: Configure appropriate pool sizes for tenant databases
- **Caching**: Update cache keys to include tenant context
- **Background Jobs**: Ensure jobs run in correct tenant context
- **Active Storage**: Configure tenant-aware blob storage

## Rollback Plan

### Emergency Rollback
1. Disable tenant middleware
2. Restore original model inheritance
3. Re-add organization_id foreign keys
4. Switch routing back to original configuration

### Data Recovery
- Maintain backups of shared database
- Keep original tenanted data until migration verification complete
- Document all schema changes for potential reversal

## Timeline Estimate

- **Phase 1-2**: Database & Model Setup (3-4 days)
- **Phase 3**: Cross-database associations (2-3 days) 
- **Phase 4**: Routing & Middleware (2 days)
- **Phase 5**: Data Migration (3-5 days depending on data volume)
- **Phase 6**: Controller Updates (2-3 days)
- **Phase 7**: Testing (3-4 days)
- **Phase 8**: Deployment & Monitoring (2-3 days)

**Total Estimate**: 17-24 days

## Risks & Mitigations

### High Risk
- **Data Loss**: Comprehensive backup and testing strategy
- **Performance Degradation**: Load testing with tenant databases
- **Cross-tenant Data Leakage**: Thorough security review

### Medium Risk  
- **Complex Rollback**: Detailed rollback procedures and testing
- **User Experience Disruption**: Staged rollout with feature flags

### Low Risk
- **Development Workflow Changes**: Team training and documentation

## Success Metrics

- All existing functionality works with tenant isolation
- No performance regression compared to current system
- Successful subdomain-based tenant routing
- Zero data loss during migration
- Comprehensive test coverage for multi-tenant scenarios

---

**Next Steps**: Review this plan with the team, get approval for the shared users approach, and begin Phase 1 implementation.