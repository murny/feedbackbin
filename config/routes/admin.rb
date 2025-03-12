# frozen_string_literal: true

namespace :admin do
  resources :changelogs
  resources :users
  resources :posts
  resources :organizations

  resource :docs, only: [ :show ]

  namespace :docs do
    # Get Started
    get :introduction
    get :installation
    get :configuration
    get :deploying

    get :components

    namespace :components do
      get :breadcrumb
      get :button
      get :toast
    end
  end

  root to: "dashboard#show"
end
