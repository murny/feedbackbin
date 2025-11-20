// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import { Alert, Dropdown, Popover, Toggle } from "tailwindcss-stimulus-components"
application.register('alert', Alert)
application.register('dropdown', Dropdown)
application.register('popover', Popover)
application.register('toggle', Toggle)
// Note: tabs controller is loaded from app/javascript/controllers/tabs_controller.js
