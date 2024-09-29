// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import { Dropdown, Toggle } from "tailwindcss-stimulus-components"
application.register('dropdown', Dropdown)
application.register('toggle', Toggle)
