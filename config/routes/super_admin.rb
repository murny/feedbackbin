# frozen_string_literal: true

namespace :super_admin do
  mount MissionControl::Jobs::Engine, at: "/jobs"

  resources :accounts

  root to: "dashboard#show"
end
