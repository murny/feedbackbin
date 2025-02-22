# frozen_string_literal: true

namespace :admin do
  resources :changelogs

  resources :documentation, only: [ :index ]
  namespace :documentation do
    resources :components, only: [ :show ]
  end

  root to: "dashboard#show"
end
