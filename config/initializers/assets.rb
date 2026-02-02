# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Add our new pure CSS stylesheets directory (Fizzy-style architecture)
# This runs alongside Tailwind during migration, will eventually replace it
Rails.application.config.assets.paths << Rails.root.join("app/assets/stylesheets")
