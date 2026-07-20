import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["menu", "button"]

  connect() {
    this.onOutsideClick = this.onOutsideClick.bind(this)
    this.onKeydown = this.onKeydown.bind(this)
  }

  disconnect() {
    this.stopListening()
  }

  toggle(event) {
    // Stop the opening click from immediately reaching the outside-click handler.
    event.stopPropagation()
    this.open ? this.hide() : this.show()
  }

  show() {
    this.menuTarget.classList.remove("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "true")
    document.addEventListener("click", this.onOutsideClick)
    document.addEventListener("keydown", this.onKeydown)
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
  }

  get open() {
    return !this.menuTarget.classList.contains("hidden")
  }
}
