# frozen_string_literal: true

pin "application", to: "feedbackbin_elements/application.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "tailwindcss-stimulus-components"
pin "highlight.js", to: "https://ga.jspm.io/npm:highlight.js@11.11.1/es/index.js"
pin_all_from FeedbackbinElements::Engine.root.join("app/javascript/feedbackbin_elements/controllers"), under: "controllers", to: "feedbackbin_elements/controllers"
