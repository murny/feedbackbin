# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "tailwindcss-stimulus-components" # @6.1.3
pin "highlight.js", to: "https://ga.jspm.io/npm:highlight.js@11.11.1/es/index.js"

pin_all_from "app/javascript/controllers", under: "controllers"
