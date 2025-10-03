import { application } from "controllers/application"

// Import Tailwind CSS Stimulus components
import { Alert, Dropdown, Popover, Tabs, Toggle } from "tailwindcss-stimulus-components"
application.register("alert", Alert)
application.register("dropdown", Dropdown)
application.register("popover", Popover)
application.register("tabs", Tabs)
application.register("toggle", Toggle)

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
