# frozen_string_literal: true

Rails.application.routes.draw do
  extend Authenticated

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # =============================================================================
  # Authentication Routes
  # These routes work in both tenanted and untenanted contexts via AccountSlug
  # middleware which moves /:account_id prefix to SCRIPT_NAME.
  # =============================================================================

  # Account creation (untenanted only - disallow_account_scope)
  resource :signup, only: %i[show create]

  # Session management
  get "sign_in", to: "sessions#new"
  resource :session, only: [ :create, :destroy ] do
    scope module: :sessions do
      resource :menu, only: [ :show ]
      resource :magic_link, only: [ :show, :create ]
      resources :magic_link_requests, only: [ :create ]
    end
  end

  # OAuth callbacks (untenanted only - disallow_account_scope)
  get "/auth/failure", to: "users/omniauth#failure"
  get "/auth/:provider/callback", to: "users/omniauth#create"
  post "/auth/:provider/callback", to: "users/omniauth#create"

  # User registration (tenanted context for joining an account)
  namespace :users do
    get "sign_up", to: "registrations#new", as: :sign_up
    resources :registrations, only: [ :create ]
    resources :password_resets, param: :token, only: [ :new, :create, :edit, :update ]
    resource :email_verification, only: [ :show, :create ] do
      get :pending, on: :collection
    end
    resource :email_change_confirmation, only: [ :show ]
  end

  # =============================================================================
  # User Settings (requires authentication)
  # =============================================================================

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

  # =============================================================================
  # User Resources
  # =============================================================================

  resources :users, only: [ :show, :destroy ] do
    scope module: "users" do
      resource :avatar, only: %i[show destroy]
    end
  end

  direct :fresh_user_avatar do |user, options|
    route_for :user_avatar, user, v: user.updated_at.to_fs(:number)
  end

  # =============================================================================
  # Core Application Resources (require account context)
  # =============================================================================

  resources :notifications, only: [ :index ] do
    scope module: :notifications do
      resource :reading, only: [ :create, :destroy ]
      collection do
        resource :bulk_reading, only: [ :create ]
      end
    end
  end

  namespace :prompts do
    resources :users, only: [ :index ]
  end

  resources :ideas do
    scope module: :ideas do
      resource :vote, only: [ :update ]
      resource :watch, only: [ :show, :create, :destroy ]
      resource :pin, only: [ :create, :destroy ]
      resource :status, only: [ :update ]

      resources :comments do
        resource :vote, only: [ :update ], module: :comments
      end
    end
    resources :taggings, only: [ :create, :destroy ]
  end
  resources :changelogs, only: [ :index, :show ]
  resources :tags, only: [ :index, :create ]

  # Roadmap
  get "roadmap", to: "roadmap#index"

  # =============================================================================
  # Admin Routes (require account context)
  # =============================================================================

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
      resources :webhooks do
        scope module: :webhooks do
          resource :activation, only: [ :create, :destroy ]
        end
      end
      resource :danger_zone, only: [ :show, :destroy ]
      resource :ownership_transfer, only: [ :new, :create ]

      root to: redirect("/admin/settings/branding")
    end
  end

  # =============================================================================
  # Invitations (public access, but require account context)
  # =============================================================================

  resources :invitations, only: [ :show ], param: :token

  # =============================================================================
  # Static Pages
  # =============================================================================

  scope controller: :static do
    get :about
    get :terms
    get :privacy
  end

  # =============================================================================
  # Staff Routes (authenticated)
  # =============================================================================

  authenticated :staff do
    draw :staff
  end

  # =============================================================================
  # Health & PWA
  # =============================================================================

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up", to: "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest", to: "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker", to: "rails/pwa#service_worker", as: :pwa_service_worker

  # =============================================================================
  # Development Tools
  # =============================================================================

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
    mount Lookbook::Engine, at: "/lookbook"
  end

  # =============================================================================
  # Root
  # =============================================================================

  root "ideas#index"
end
