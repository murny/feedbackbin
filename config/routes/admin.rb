# frozen_string_literal: true

namespace :admin do
  resources :changelogs
  resources :users
  resources :posts
  resources :organizations

  resources :docs, only: [ :index ]
  namespace :docs do
    resources :components, only: [ :show ]
  end

  root to: "dashboard#show"
end
