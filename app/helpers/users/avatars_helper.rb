# frozen_string_literal: true

module Users
  module AvatarsHelper
    AVATAR_COLORS = %w[
      #AF2E1B #CC6324 #3B4B59 #BFA07A #ED8008 #ED3F1C #BF1B1B #736B1E #D07B53
      #736356 #AD1D1D #BF7C2A #C09C6F #698F9C #7C956B #5D618F #3B3633 #67695E
    ]

    # Returns the background color for the user's avatar initials using a deterministic algorithm based on the user's ID.
    def avatar_background_color(user)
      AVATAR_COLORS[Zlib.crc32(user.to_param) % AVATAR_COLORS.size]
    end

    def avatar_tag(user, **options)
      link_to user_path(user), title: user.title, data: { turbo_frame: "_top" } do
        image_tag fresh_user_avatar_path(user), role: "presentation", **options
      end
    end
  end
end
