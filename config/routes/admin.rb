# frozen_string_literal: true

namespace :admin do
  resources :changelogs

  namespace :documentation do
    resources :components, only: [ :show ]
  end

  root to: "dashboard#show"
end
