# frozen_string_literal: true

namespace :admin do
  resources :changelogs

  resource :docs do
    # Showcase of Components
    get :buttons
  end

  root to: "dashboard#show"
end
