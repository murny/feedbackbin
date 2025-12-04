# Use this hook to configure the litestream-ruby gem.
# All configuration options will be available as environment variables, e.g.
# config.replica_bucket becomes LITESTREAM_REPLICA_BUCKET
# This allows you to configure Litestream using Rails encrypted credentials,
# or some other mechanism where the values are only available at runtime.

Rails.application.configure do
  # Only configure Litestream in production to avoid unnecessary overhead in development/test
  if Rails.env.production?
    # Configure Litestream through environment variables. Use Rails encrypted credentials for secrets.
    litestream_credentials = Rails.application.credentials.litestream

    # Replica-specific bucket location
    # This should be your S3 bucket name (e.g., "my-app-backups")
    # or full URL for S3-compatible services (e.g., "myapp.fra1.digitaloceanspaces.com")
    config.litestream.replica_bucket = litestream_credentials&.replica_bucket

    # Replica-specific authentication credentials for S3
    # These are your AWS access key ID and secret access key
    config.litestream.replica_key_id = litestream_credentials&.access_key_id
    config.litestream.replica_access_key = litestream_credentials&.secret_access_key

    # Replica-specific region (e.g., "us-east-1", "eu-west-1")
    config.litestream.replica_region = litestream_credentials&.region || "us-east-1"

    # Optional: Set endpoint for S3-compatible services (e.g., DigitalOcean Spaces, Backblaze B2)
    # config.litestream.replica_endpoint = litestream_credentials&.endpoint

    # Optional: Configure the Litestream dashboard authentication
    # Uncomment these lines to enable dashboard access with authentication
    # config.litestream.username = litestream_credentials&.username
    # config.litestream.password = litestream_credentials&.password
  end
end
