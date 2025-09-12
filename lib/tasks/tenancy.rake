# frozen_string_literal: true

namespace :tenancy do
  desc "Migrate existing data to tenant databases"
  task migrate_data: :environment do
    puts "Starting data migration to tenant databases..."
    
    Organization.find_each do |org|
      puts "Processing organization: #{org.name} (#{org.subdomain})"
      
      # Skip if no subdomain
      if org.subdomain.blank?
        puts "  Skipping #{org.name} - no subdomain"
        next
      end
      
      # Create tenant database if it doesn't exist
      unless ApplicationRecord.tenant_exist?(org.subdomain)
        puts "  Creating tenant database for #{org.subdomain}"
        ApplicationRecord.create_tenant(org.subdomain)
        
        # Run tenant migrations
        ApplicationRecord.with_tenant(org.subdomain) do
          Rails.application.load_tasks
          Rake::Task['db:migrate'].invoke
        end
      end
      
      ApplicationRecord.with_tenant(org.subdomain) do
        migrate_organization_data(org)
      end
      
      puts "  ✓ Completed migration for #{org.name}"
    end
    
    puts "Data migration completed!"
  end

  desc "Verify tenant data integrity"
  task verify_data: :environment do
    puts "Verifying tenant data integrity..."
    
    Organization.find_each do |org|
      next if org.subdomain.blank?
      
      puts "Verifying organization: #{org.name} (#{org.subdomain})"
      
      ApplicationRecord.with_tenant(org.subdomain) do
        # Verify categories
        tenant_categories = Category.count
        original_categories = org.categories.count
        puts "  Categories: #{tenant_categories}/#{original_categories}"
        
        # Verify posts
        tenant_posts = Post.count
        original_posts = org.posts.count
        puts "  Posts: #{tenant_posts}/#{original_posts}"
        
        # Verify comments
        tenant_comments = Comment.count
        original_comments = org.comments.count
        puts "  Comments: #{tenant_comments}/#{original_comments}"
        
        # Verify likes
        tenant_likes = Like.count
        original_likes = org.likes.count
        puts "  Likes: #{tenant_likes}/#{original_likes}"
      end
    end
    
    puts "Verification completed!"
  end

  desc "Clean up organization_id columns after successful migration"
  task cleanup_organization_ids: :environment do
    puts "WARNING: This will remove organization_id columns from tenanted tables!"
    puts "Make sure data migration is complete and verified."
    print "Continue? (y/N): "
    
    response = STDIN.gets.chomp.downcase
    unless response == 'y' || response == 'yes'
      puts "Cleanup cancelled."
      exit
    end
    
    ActiveRecord::Migration.new.tap do |migration|
      # Remove organization_id from tenanted tables
      %w[categories changelogs comments likes posts post_statuses].each do |table|
        if migration.column_exists?(table.to_sym, :organization_id)
          puts "Removing organization_id from #{table}"
          migration.remove_foreign_key table.to_sym, :organizations if migration.foreign_key_exists?(table.to_sym, :organizations)
          migration.remove_index table.to_sym, :organization_id if migration.index_exists?(table.to_sym, :organization_id)
          migration.remove_column table.to_sym, :organization_id
        end
      end
    end
    
    puts "Cleanup completed!"
  end

  private

  def migrate_organization_data(org)
    # Migrate categories
    puts "    Migrating categories..."
    org.categories.find_each do |category|
      Category.create!(
        name: category.name,
        description: category.description,
        created_at: category.created_at,
        updated_at: category.updated_at
      )
    end

    # Create category mapping for posts
    category_mapping = {}
    org.categories.each do |original_category|
      tenant_category = Category.find_by(name: original_category.name)
      category_mapping[original_category.id] = tenant_category.id if tenant_category
    end

    # Migrate post statuses first (needed for posts)
    puts "    Migrating post statuses..."
    status_mapping = {}
    org.post_statuses.find_each do |status|
      new_status = PostStatus.create!(
        name: status.name,
        color: status.color,
        position: status.position,
        created_at: status.created_at,
        updated_at: status.updated_at
      )
      status_mapping[status.id] = new_status.id
    end

    # Migrate posts
    puts "    Migrating posts..."
    post_mapping = {}
    org.posts.includes(:rich_text_body).find_each do |post|
      new_post = Post.create!(
        title: post.title,
        author_id: post.author_id,
        category_id: category_mapping[post.category_id],
        post_status_id: status_mapping[post.post_status_id],
        pinned: post.pinned,
        comments_count: post.comments_count,
        likes_count: post.likes_count,
        created_at: post.created_at,
        updated_at: post.updated_at
      )
      
      # Copy ActionText content
      if post.body.present?
        new_post.body = post.body.body
        new_post.save!
      end
      
      post_mapping[post.id] = new_post.id
    end

    # Migrate comments
    puts "    Migrating comments..."
    comment_mapping = {}
    
    # Migrate top-level comments first
    org.comments.where(parent_id: nil).includes(:rich_text_body).find_each do |comment|
      new_comment = Comment.create!(
        creator_id: comment.creator_id,
        post_id: post_mapping[comment.post_id],
        parent_id: nil,
        likes_count: comment.likes_count,
        created_at: comment.created_at,
        updated_at: comment.updated_at
      )
      
      # Copy ActionText content
      if comment.body.present?
        new_comment.body = comment.body.body
        new_comment.save!
      end
      
      comment_mapping[comment.id] = new_comment.id
    end
    
    # Then migrate reply comments
    org.comments.where.not(parent_id: nil).includes(:rich_text_body).find_each do |comment|
      new_comment = Comment.create!(
        creator_id: comment.creator_id,
        post_id: post_mapping[comment.post_id],
        parent_id: comment_mapping[comment.parent_id],
        likes_count: comment.likes_count,
        created_at: comment.created_at,
        updated_at: comment.updated_at
      )
      
      # Copy ActionText content
      if comment.body.present?
        new_comment.body = comment.body.body
        new_comment.save!
      end
      
      comment_mapping[comment.id] = new_comment.id
    end

    # Migrate likes
    puts "    Migrating likes..."
    org.likes.find_each do |like|
      likeable_id = case like.likeable_type
                   when 'Post'
                     post_mapping[like.likeable_id]
                   when 'Comment'
                     comment_mapping[like.likeable_id]
                   else
                     like.likeable_id
                   end
      
      if likeable_id
        Like.create!(
          voter_id: like.voter_id,
          likeable_type: like.likeable_type,
          likeable_id: likeable_id,
          created_at: like.created_at,
          updated_at: like.updated_at
        )
      end
    end

    # Migrate changelogs
    puts "    Migrating changelogs..."
    org.changelogs.includes(:rich_text_description).find_each do |changelog|
      new_changelog = Changelog.create!(
        title: changelog.title,
        kind: changelog.kind,
        published_at: changelog.published_at,
        created_at: changelog.created_at,
        updated_at: changelog.updated_at
      )
      
      # Copy ActionText content
      if changelog.description.present?
        new_changelog.description = changelog.description.body
        new_changelog.save!
      end
    end
  end
end