# frozen_string_literal: true

# Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  extend Authenticated

  # Direct route helper for user avatars with cache busting
  direct :fresh_user_avatar do |user, options|
    route_for :user_avatar, user, v: user.updated_at.to_fs(:number)
  end

  if Rails.application.config.multi_tenant
    constraints subdomain: "app" do
      resources :organizations, only: [ :new, :create ]

      authenticated :super_admin do
        draw :super_admin
      end
    end

    constraints subdomain: /^(?!app)[^.]+$/ do
      draw :tenant
    end
  else
    draw :tenant
  end

  scope controller: :static do
    get :about
    get :terms
    get :privacy
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up", to: "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest", to: "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker", to: "rails/pwa#service_worker", as: :pwa_service_worker

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
