# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.local?

  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"]

  provider :facebook, ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_APP_SECRET"]

  provider :apple, ENV["CLIENT_ID"], "",
    {
      scope: "email name",
      team_id: ENV["TEAM_ID"],
      key_id: ENV["KEY_ID"],
      pem: ENV["PRIVATE_KEY"]
    }
end
