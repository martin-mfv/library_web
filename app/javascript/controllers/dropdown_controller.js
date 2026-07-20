import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["menu", "button"]

  connect() {
    this.onOutsideClick = this.onOutsideClick.bind(this)
    this.onKeydown = this.onKeydown.bind(this)
    this.onBeforeVisit = this.onBeforeVisit.bind(this)
    this.onDropdownOpen = this.onDropdownOpen.bind(this)
    document.addEventListener("dropdown:open", this.onDropdownOpen)
  }

  disconnect() {
    document.removeEventListener("dropdown:open", this.onDropdownOpen)
    this.stopListening()
  }

  toggle(event) {
    event.stopPropagation()
    this.open ? this.hide() : this.show()
  }

  show() {
    document.dispatchEvent(new CustomEvent("dropdown:open", { detail: { source: this } }))
    this.menuTarget.classList.remove("hidden")
    this.positionMenu()
    this.buttonTarget.setAttribute("aria-expanded", "true")
    document.addEventListener("click", this.onOutsideClick)
    document.addEventListener("keydown", this.onKeydown)
    document.addEventListener("turbo:before-visit", this.onBeforeVisit)
  }

  hide() {
    this.menuTarget.classList.add("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "false")
    this.stopListening()
  }

  onOutsideClick(event) {
    if (!this.element.contains(event.target)) this.hide()
  }

  onKeydown(event) {
    if (event.key === "Escape") this.hide()
  }

  stopListening() {
    document.removeEventListener("click", this.onOutsideClick)
    document.removeEventListener("keydown", this.onKeydown)
    document.removeEventListener("turbo:before-visit", this.onBeforeVisit)
  }

  onBeforeVisit() {
    this.hide()
  }

  onDropdownOpen(event) {
    if (event.detail.source !== this) this.hide()
  }

  positionMenu() {
    this.menuTarget.classList.remove("bottom-full", "mb-2")
    this.menuTarget.classList.add("top-full", "mt-2")

    const menuRect = this.menuTarget.getBoundingClientRect()
    const viewportHeight = window.innerHeight
    const spaceBelow = viewportHeight - menuRect.top
    const spaceAbove = menuRect.bottom

    if (menuRect.bottom > viewportHeight && spaceAbove > spaceBelow) {
      this.menuTarget.classList.remove("top-full", "mt-2")
      this.menuTarget.classList.add("bottom-full", "mb-2")
    }
  }

  get open() {
    return !this.menuTarget.classList.contains("hidden")
  }
}
