# frozen_string_literal: true

Rails.application.routes.draw do
  extend Authenticated

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # authentification
  get "sign_in", to: "users/sessions#new"
  get "sign_up", to: "users/registrations#new"

  namespace :users do
    resources :password_resets, param: :token, only: [:new, :create, :edit, :update]
    resource :session, only: [:create, :destroy]
    resource :email_verification, only: [:show, :create]
    resources :registrations, only: [:create]

    namespace :settings do
      resources :sessions, only: [:index]
      resource :profile, only: [:edit, :update]
      resource :password, only: [:edit, :update]
      resource :email, only: [:edit, :update]
    end
  end

  resources :users, only: [:show]
  resources :posts

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
