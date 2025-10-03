# frozen_string_literal: true

FeedbackbinElements::Engine.routes.draw do
  scope module: "docs" do
    root to: "components#index"

    get "accordion", to: "components#accordion", as: :accordion
    get "alert", to: "components#alert", as: :alert
    get "avatar", to: "components#avatar", as: :avatar
    get "badge", to: "components#badge", as: :badge
    get "breadcrumb", to: "components#breadcrumb", as: :breadcrumb
    get "button", to: "components#button", as: :button
    get "card", to: "components#card", as: :card
    get "dropdown_menu", to: "components#dropdown_menu", as: :dropdown_menu
    get "forms", to: "components#forms", as: :forms
    get "popover", to: "components#popover", as: :popover
    get "tabs", to: "components#tabs", as: :tabs
    get "toast", to: "components#toast", as: :toast
  end
end
