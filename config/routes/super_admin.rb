# frozen_string_literal: true

namespace :super_admin do
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
      get :accordion
      get :alert
      get :avatar
      get :badge
      get :breadcrumb
      get :button
      get :card
      get :dropdown_menu
      get :forms
      get :popover
      get :tabs
      get :toast
    end
  end

  root to: "dashboard#show"
end
