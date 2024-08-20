# frozen_string_literal: true

Rails.application.routes.draw do
  # authentification
  get "sign_in", to: "users/sessions#new"
  get "sign_up", to: "users/registrations#new"

  namespace :users do
    resources :password_resets, param: :token, only: [:new, :create, :edit, :update]
    resource :session, only: [:create, :destroy]
    resource :email_verification, only: [:show, :create]
    resources :registrations, only: [:create]
  end

  resources :posts
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up", to: "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker", to: "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest", to: "rails/pwa#manifest", as: :pwa_manifest

  root "posts#index"
end
