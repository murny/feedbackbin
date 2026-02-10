// Utility functions for handling CSS transitions with Stimulus controllers
// Based on tailwindcss-stimulus-components
// https://github.com/excid3/tailwindcss-stimulus-components

// Helper to safely split class strings and filter out empty values
function splitClasses(classString) {
  return classString.split(' ').filter(Boolean)
}

// Main transition function:
//
//   transition(element, true)  // Enter
//   transition(element, false) // Leave
//
// Can be used with custom transition options:
//
//   transition(element, true, {
//     enter: "transition ease-out duration-300",
//     enterFrom: "opacity-0",
//     enterTo: "opacity-100"
//   })
export async function transition(element, state, transitionOptions = {}) {
  if (state) {
    await enter(element, transitionOptions)
  } else {
    await leave(element, transitionOptions)
  }
}

// Enter transition - shows element with animation
//
// Works with data attributes:
//   data-transition-enter="transition ease-out duration-300"
//   data-transition-enter-from="opacity-0"
//   data-transition-enter-to="opacity-100"
//   data-toggle-class="display-none"
//
// Or can be called with options:
//   enter(element, { enter: "...", enterFrom: "...", enterTo: "..." })
export async function enter(element, transitionOptions = {}) {
  const { transitionClasses, fromClasses, toClasses, toggleClass } = getTransitionOptions("Enter", element, transitionOptions)

  return performTransitions(element, {
    firstFrame() {
      element.classList.add(...splitClasses(transitionClasses))
      element.classList.add(...splitClasses(fromClasses))
      element.classList.remove(...splitClasses(toClasses))
      element.classList.remove(...splitClasses(toggleClass))
    },
    secondFrame() {
      element.classList.remove(...splitClasses(fromClasses))
      element.classList.add(...splitClasses(toClasses))
    },
    ending() {
      element.classList.remove(...splitClasses(transitionClasses))
    }
  })
}

// Leave transition - hides element with animation
//
// Works with data attributes:
//   data-transition-leave="transition ease-in duration-200"
//   data-transition-leave-from="opacity-100"
//   data-transition-leave-to="opacity-0"
//   data-toggle-class="display-none"
export async function leave(element, transitionOptions = {}) {
  const { transitionClasses, fromClasses, toClasses, toggleClass } = getTransitionOptions("Leave", element, transitionOptions)

  return performTransitions(element, {
    firstFrame() {
      element.classList.add(...splitClasses(fromClasses))
      element.classList.remove(...splitClasses(toClasses))
      element.classList.add(...splitClasses(transitionClasses))
    },
    secondFrame() {
      element.classList.remove(...splitClasses(fromClasses))
      element.classList.add(...splitClasses(toClasses))
    },
    ending() {
      element.classList.remove(...splitClasses(transitionClasses))
      element.classList.add(...splitClasses(toggleClass))
    }
  })
}

// Get transition options from data attributes or passed options
function getTransitionOptions(type, element, transitionOptions) {
  return {
    transitionClasses: element.dataset[`transition${type}`] || transitionOptions[type.toLowerCase()] || type.toLowerCase(),
    fromClasses: element.dataset[`transition${type}From`] || transitionOptions[`${type.toLowerCase()}From`] || `${type.toLowerCase()}-from`,
    toClasses: element.dataset[`transition${type}To`] || transitionOptions[`${type.toLowerCase()}To`] || `${type.toLowerCase()}-to`,
    toggleClass: element.dataset.toggleClass || transitionOptions.toggleClass || transitionOptions.toggle || 'display-none'
  }
}

// Set up transition state on element
function setupTransition(element) {
  element._stimulus_transition = {
    timeout: null,
    interrupted: false
  }
}

// Cancel any in-progress transition
export function cancelTransition(element) {
  if(element._stimulus_transition && element._stimulus_transition.interrupt) {
    element._stimulus_transition.interrupt()
  }
}

// Perform the actual transition with proper RAF staging
function performTransitions(element, transitionStages) {
  if (element._stimulus_transition) cancelTransition(element)

  let interrupted, firstStageComplete, secondStageComplete
  setupTransition(element)

  element._stimulus_transition.cleanup = () => {
    if(! firstStageComplete) transitionStages.firstFrame()
    if(! secondStageComplete) transitionStages.secondFrame()

    transitionStages.ending()
    element._stimulus_transition = null
  }

  element._stimulus_transition.interrupt = () => {
    interrupted = true
    if(element._stimulus_transition.timeout) {
      clearTimeout(element._stimulus_transition.timeout)
    }
    element._stimulus_transition.cleanup()
  }

  return new Promise((resolve) => {
    if(interrupted) return

    requestAnimationFrame(() => {
      if(interrupted) return

      transitionStages.firstFrame()
      firstStageComplete = true

      requestAnimationFrame(() => {
        if(interrupted) return

        transitionStages.secondFrame()
        secondStageComplete = true

        if(element._stimulus_transition) {
          element._stimulus_transition.timeout = setTimeout(() => {
            if(interrupted) {
              resolve()
              return
            }

            element._stimulus_transition.cleanup()
            resolve()
          }, getAnimationDuration(element))
        }
      })
    })
  })
}

// Calculate total animation/transition duration
function getAnimationDuration(element) {
  let duration = Number(getComputedStyle(element).transitionDuration.replace(/,.*/, '').replace('s', '')) * 1000
  let delay = Number(getComputedStyle(element).transitionDelay.replace(/,.*/, '').replace('s', '')) * 1000

  if (duration === 0) duration = Number(getComputedStyle(element).animationDuration.replace('s', '')) * 1000

  return duration + delay
}
