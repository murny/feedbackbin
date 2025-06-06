# frozen_string_literal: true

module Users
  class AvatarsController < ApplicationController
    include ActiveStorage::Streaming
    allow_unauthenticated_access only: %i[show]
    skip_after_action :verify_authorized

    def show
      @user = User.find(params[:user_id])

      if stale?(etag: @user)
        expires_in 30.minutes, public: true, stale_while_revalidate: 1.week

        if @user.avatar.attached?
          avatar_variant = @user.avatar.variant(SQUARE_WEBP_VARIANT).processed
          send_webp_blob_file avatar_variant.key
        else
          # render initials
          render formats: :svg
        end
      end
    end

    def destroy
      Current.user.avatar.destroy
      redirect_to user_settings_profile_path, notice: t(".avatar_removed")
    end

    private

      SQUARE_WEBP_VARIANT = { resize_to_limit: [ 512, 512 ], format: :webp }

    def send_webp_blob_file(key)
      send_file ActiveStorage::Blob.service.path_for(key), content_type: "image/webp", disposition: :inline
    end
  end
end
