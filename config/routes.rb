# frozen_string_literal: true

Rails.application.routes.draw do
  extend Authenticated

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resource :first_run, only: %i[show create]

  # authentification
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

  namespace :user_settings do
    resource :account, only: [ :show, :update ]
    resources :active_sessions, only: [ :index, :destroy ]
    resources :connected_accounts, only: [ :destroy ]
    resource :email, only: [ :update ]
    resource :password, only: [ :show, :update ]
    resource :preferences, only: [ :show, :update ]
    resource :profile, only: [ :show, :update ]
  end

  resources :users, only: [ :show, :destroy ] do
    scope module: "users" do
      resource :avatar, only: %i[show destroy]
    end
  end

  direct :fresh_user_avatar do |user, options|
    route_for :user_avatar, user, v: user.updated_at.to_fs(:number)
  end

  resource :like, only: [ :update ]

  resources :posts do
    scope module: :posts do
      resource :pin, only: [ :create, :destroy ]
    end
  end
  resources :comments, except: [ :index, :new ]
  resources :changelogs, only: [ :index, :show ]

  namespace :admin do
    root to: "dashboard#show"

    namespace :settings do
      resources :organization_invitations, only: [ :index, :new, :create, :destroy ]
      resources :memberships, except: [ :show ]
    end
  end

  resources :organizations, only: [ :new, :create ] do
    scope module: :organizations do
      resource :switch, only: %i[create]
    end
  end

  scope controller: :static do
    get :about
    get :terms
    get :privacy
  end

  authenticated :super_admin do
    draw :super_admin
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

  root "posts#index"
end
