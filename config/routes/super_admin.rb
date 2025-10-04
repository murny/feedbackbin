# frozen_string_literal: true

namespace :super_admin do
  mount MissionControl::Jobs::Engine, at: "/jobs"
  mount FeedbackbinElements::Engine, at: "/docs/components", as: :feedbackbin_elements

  resources :organizations

  root to: "dashboard#show"
end
