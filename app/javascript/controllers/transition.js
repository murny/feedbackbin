// Utility functions for handling CSS transitions with Stimulus controllers
// Based on tailwindcss-stimulus-components pattern

// Show element with enter animation
export function enter(element) {
  return new Promise((resolve) => {
    // If no transition is defined, resolve immediately
    const duration = getTransitionDuration(element)

    if (duration === 0) {
      resolve()
      return
    }

    // Listen for transition end
    const onTransitionEnd = (event) => {
      if (event.target === element) {
        element.removeEventListener('transitionend', onTransitionEnd)
        resolve()
      }
    }

    element.addEventListener('transitionend', onTransitionEnd)

    // Trigger animation by setting data-state
    requestAnimationFrame(() => {
      element.dataset.state = 'open'
    })

    // Fallback timeout in case transitionend doesn't fire
    setTimeout(() => {
      element.removeEventListener('transitionend', onTransitionEnd)
      resolve()
    }, duration + 100)
  })
}

// Hide element with leave animation
export function leave(element) {
  return new Promise((resolve) => {
    // If no transition is defined, resolve immediately
    const duration = getTransitionDuration(element)

    if (duration === 0) {
      resolve()
      return
    }

    // Listen for transition end
    const onTransitionEnd = (event) => {
      if (event.target === element) {
        element.removeEventListener('transitionend', onTransitionEnd)
        resolve()
      }
    }

    element.addEventListener('transitionend', onTransitionEnd)

    // Trigger animation by setting data-state
    requestAnimationFrame(() => {
      element.dataset.state = 'closed'
    })

    // Fallback timeout in case transitionend doesn't fire
    setTimeout(() => {
      element.removeEventListener('transitionend', onTransitionEnd)
      resolve()
    }, duration + 100)
  })
}

// Get transition duration from computed styles
function getTransitionDuration(element) {
  const styles = window.getComputedStyle(element)
  const duration = styles.transitionDuration || '0s'

  // Parse duration (can be in seconds or milliseconds)
  const match = duration.match(/^([\d.]+)(m?s)$/)
  if (!match) return 0

  const value = parseFloat(match[1])
  const unit = match[2]

  return unit === 'ms' ? value : value * 1000
}
