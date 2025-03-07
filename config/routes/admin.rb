# frozen_string_literal: true

namespace :admin do
  resources :changelogs
  resources :users
  resources :posts
  resources :organizations

  resource :docs do
    # Get Started
    get :introduction
    get :installation
    get :configuration
    get :deploying

    # Components
    get :breadcrumb
    get :button
    get :toast
  end

  root to: "dashboard#show"
end
