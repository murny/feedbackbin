# frozen_string_literal: true

namespace :admin do
  resources :changelogs

  root to: "dashboard#show"
end
