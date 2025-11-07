# Ensure storage subdirectories exist with correct ownership
# This prevents permission issues in Docker and other deployment scenarios
# by creating directories at runtime as the Rails user
Rails.application.config.after_initialize do
  %w[db files].each do |dir|
    Rails.root.join("storage", dir).mkpath
  end
end
