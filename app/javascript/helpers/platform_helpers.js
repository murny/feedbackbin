export function isMobile() {
  return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
}

export function isAppleDevice() {
  return /Mac|iPhone|iPad|iPod/i.test(navigator.platform)
}

export function isTouchDevice() {
  return "ontouchstart" in window || navigator.maxTouchPoints > 0
}
