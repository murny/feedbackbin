# frozen_string_literal: true

Rails.application.routes.draw do
  extend Authenticated

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resource :first_run, only: %i[show create]

  # authentification
  get "sign_in", to: "users/sessions#new"
  get "sign_up", to: "users/registrations#new"
  get "/auth/failure", to: "sessions/omniauth#failure"
  get "/auth/:provider/callback", to: "sessions/omniauth#create"
  post "/auth/:provider/callback", to: "sessions/omniauth#create"

  namespace :users do
    resources :password_resets, param: :token, only: [:new, :create, :edit, :update]
    resource :session, only: [:create, :destroy]
    resource :email_verification, only: [:show, :create]
    resources :registrations, only: [:create]

    namespace :settings do
      resources :sessions, only: [:index, :destroy]
      resource :profile, only: [:show, :update]
      resource :account, only: [:show, :update]
      resource :appearance, only: [:show, :update]
      resource :notifications, only: [:show, :update]
      resource :password, only: [:update]
      resource :email, only: [:update]
    end

    namespace :sessions do
      resource :passwordless, only: [:new, :edit, :create]
    end
  end

  resources :users, only: :show do
    scope module: "users" do
      resource :avatar, only: %i[show destroy]
    end
  end

  direct :fresh_user_avatar do |user, options|
    route_for :user_avatar, user, v: user.updated_at.to_fs(:number)
  end

  resource :like, only: [:update]
  resources :posts
  resources :comments

  scope controller: :static do
    get :about
    get :terms
    get :privacy
  end

  authenticated :admin do
    draw :admin
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up", to: "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker", to: "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest", to: "rails/pwa#manifest", as: :pwa_manifest

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end

  root "posts#index"
end
