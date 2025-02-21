# frozen_string_literal: true

namespace :admin do
  resources :changelogs

  namespace :documentation do
    # Showcase of Components
    resource :components do
      get :buttons
    end
  end

  root to: "dashboard#show"
end
