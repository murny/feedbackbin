# frozen_string_literal: true

# Tenant application routes - shared by both single-tenant and multi-tenant modes
# In single-tenant mode: These routes are available on the main domain
# In multi-tenant mode: These routes are available on tenant subdomains

# First run setup flow
resource :first_run, only: %i[show create]

# Authentication routes
get "sign_in", to: "users/sessions#new"
get "sign_up", to: "users/registrations#new"

get "/auth/failure", to: "users/omniauth#failure"
get "/auth/:provider/callback", to: "users/omniauth#create"
post "/auth/:provider/callback", to: "users/omniauth#create"

namespace :users do
  resources :password_resets, param: :token, only: [ :new, :create, :edit, :update ]
  resource :session, only: [ :create, :destroy ]
  resource :email_verification, only: [ :show, :create ]
  resources :registrations, only: [ :create ]
end

# User settings
namespace :user_settings do
  resource :account, only: [ :show, :update ]
  resources :active_sessions, only: [ :index, :destroy ]
  resources :connected_accounts, only: [ :destroy ]
  resource :email, only: [ :update ]
  resource :password, only: [ :show, :update ]
  resource :preferences, only: [ :show, :update ]
  resource :profile, only: [ :show, :update ]

  root to: redirect("/user_settings/profile")
end

# User profiles and avatars
resources :users, only: [ :show, :destroy ] do
  scope module: "users" do
    resource :avatar, only: %i[show destroy]
  end
end

# Feedback functionality
resource :like, only: [ :update ]

resources :posts do
  scope module: :posts do
    resource :pin, only: [ :create, :destroy ]
    resource :status, only: [ :update ]
  end
end

resources :comments, except: [ :index, :new ]
resources :changelogs, only: [ :index, :show ]

# Roadmap
get "roadmap", to: "roadmap#index"

# Admin section
namespace :admin do
  root to: "dashboard#show"

  resources :users, only: [ :index, :show ]
  resources :posts, only: [ :index, :show ]

  namespace :settings do
    resource :branding, only: [ :show, :update ]
    resources :invitations, only: [ :index, :new, :create, :destroy ]
    resources :memberships, only: [ :index, :destroy ]
    resources :post_statuses
    resource :danger_zone, only: [ :show, :destroy ]

    root to: redirect("/admin/settings/branding")
  end
end

# Root route
root "posts#index"
