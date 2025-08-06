// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import { Alert, Popover, Tabs, Toggle } from "tailwindcss-stimulus-components"
application.register('alert', Alert)
application.register('popover', Popover)
application.register('tabs', Tabs)
application.register('toggle', Toggle)
