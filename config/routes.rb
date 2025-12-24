# frozen_string_literal: true

Rails.application.routes.draw do
  extend Authenticated

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resource :first_run, only: %i[show create]

  # authentification
  get "sign_in", to: "users/sessions#new"
  get "sign_up", to: "users/registrations#new"
  get "magic_sign_in", to: "users/magic_sessions#new"
  post "magic_session", to: "users/magic_sessions#create"

  get "/auth/failure", to: "users/omniauth#failure"
  get "/auth/:provider/callback", to: "users/omniauth#create"
  post "/auth/:provider/callback", to: "users/omniauth#create"

  namespace :users do
    resources :password_resets, param: :token, only: [ :new, :create, :edit, :update ]
    resource :email_verification, only: [ :show, :create ]
    resources :registrations, only: [ :create ]
  end

  resource :session, only: [ :create, :destroy ], controller: "users/sessions" do
    scope module: :sessions do
      resource :menu, only: [ :show ]
      resource :magic_link, only: [ :show, :create ]
    end
  end

  namespace :user_settings do
    resource :account, only: [ :show ]
    resources :active_sessions, only: [ :index, :destroy ]
    resources :connected_accounts, only: [ :destroy ]
    resource :email, only: [ :update ]
    resource :password, only: [ :show, :update ]
    resource :preferences, only: [ :show, :update ]
    resource :profile, only: [ :show, :update ]

    root to: redirect("/user_settings/profile")
  end

  resources :users, only: [ :show, :destroy ] do
    scope module: "users" do
      resource :avatar, only: %i[show destroy]
    end
  end

  direct :fresh_user_avatar do |user, options|
    route_for :user_avatar, user, v: user.updated_at.to_fs(:number)
  end

  resource :vote, only: [ :update ]

  resources :ideas do
    scope module: :ideas do
      resource :pin, only: [ :create, :destroy ]
      resource :status, only: [ :update ]
    end
  end
  resources :comments, except: [ :index, :new ]
  resources :changelogs, only: [ :index, :show ]

  # Roadmap
  get "roadmap", to: "roadmap#index"

  namespace :admin do
    root to: "dashboard#show"

    resources :users, only: [ :index, :show ] do
      scope module: :users do
        resource :role, only: [ :update ]
        resource :activation, only: [ :create, :destroy ]
      end
    end
    resources :ideas, only: [ :index, :show ]
    resources :invitations, only: [ :index, :new, :create, :destroy ] do
      member do
        post :resend
      end
    end

    namespace :settings do
      resource :branding, only: [ :show, :update ]
      resources :statuses
      resources :boards
      resource :danger_zone, only: [ :show, :destroy ]
      resource :ownership_transfer, only: [ :new, :create ]

      root to: redirect("/admin/settings/branding")
    end
  end

  # Public invitation acceptance
  resources :invitations, only: [ :show ], param: :token

  scope controller: :static do
    get :about
    get :terms
    get :privacy
  end

  authenticated :staff do
    draw :staff
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up", to: "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest", to: "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker", to: "rails/pwa#service_worker", as: :pwa_service_worker

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
    mount Lookbook::Engine, at: "/lookbook"
  end

  root "ideas#index"
end
