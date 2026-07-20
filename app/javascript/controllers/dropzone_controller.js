import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["input", "zone", "list", "submit", "visibility"]
  static values = { directUploadUrl: String, createUrl: String, rootUrl: String }

  connect() {
    this.entries = []
    this.uploading = false
  }

  browse() {
    this.inputTarget.click()
  }

  onKeydown(event) {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault()
      this.browse()
    }
  }

  filesSelected(event) {
    this.queueFiles(event.target.files)
    this.inputTarget.value = ""
  }

  onDragover(event) {
    event.preventDefault()
    this.highlight()
  }

  onDragleave(event) {
    if (this.zoneTarget.contains(event.relatedTarget)) return
    this.unhighlight()
  }

  onDrop(event) {
    event.preventDefault()
    this.unhighlight()
    this.queueFiles(event.dataTransfer.files)
  }

  highlight() {
    this.zoneTarget.classList.add("border-primary", "bg-primary-soft")
    this.zoneTarget.classList.remove("border-line", "bg-canvas")
  }

  unhighlight() {
    this.zoneTarget.classList.remove("border-primary", "bg-primary-soft")
    this.zoneTarget.classList.add("border-line", "bg-canvas")
  }

  queueFiles(fileList) {
    const files = Array.from(fileList)
    if (files.length === 0) return

    files.forEach((file) => this.addEntry(file))
    this.updateSubmitState()
  }

  addEntry(file) {
    const fingerprint = `${file.name}-${file.size}-${file.lastModified}`
    if (this.entries.some((entry) => entry.fingerprint === fingerprint)) return

    const row = this.buildRow(file.name)
    const entry = {
      file,
      row,
      fingerprint,
      status: "queued"
    }

    this.setRowStatus(row, "queued")
    row.root.dataset.fingerprint = fingerprint

    this.entries.push(entry)
  }

  async submitUploads() {
    if (this.uploading) return

    const queuedEntries = this.entries.filter((entry) => entry.status === "queued")
    if (queuedEntries.length === 0) return

    this.uploading = true
    this.updateSubmitState()
    this.zoneTarget.classList.add("opacity-80")

    let failed = false
    for (const entry of queuedEntries) {
      const ok = await this.uploadEntry(entry)
      if (!ok) failed = true
    }

    this.uploading = false
    this.zoneTarget.classList.remove("opacity-80")
    this.updateSubmitState()

    if (!failed) {
      window.location.assign(this.rootUrlValue)
      return
    }

  }

  uploadEntry(entry) {
    entry.status = "uploading"
    this.setRowStatus(entry.row, "uploading")

    return new Promise((resolve) => {
      const upload = new DirectUpload(entry.file, this.directUploadUrlValue)

      upload.create((error, blob) => {
        if (error) {
          entry.status = "failed"
          this.setRowStatus(entry.row, "failed")
          resolve(false)
        } else {
          this.persist(blob, entry)
            .then((ok) => {
              entry.status = ok ? "done" : "failed"
              if (!ok) this.setRowStatus(entry.row, "failed")
              resolve(ok)
            })
            .catch(() => {
              entry.status = "failed"
              this.setRowStatus(entry.row, "failed")
              resolve(false)
            })
        }
      })
    })
  }

  persist(blob, entry) {
    return fetch(this.createUrlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": this.csrfToken
      },
      body: JSON.stringify({
        library_file: {
          name: entry.file.name,
          signed_id: blob.signed_id,
          visibility: this.visibilityTarget.value
        }
      })
    })
      .then((response) => response.ok)
  }

  buildRow(name) {
    const root = document.createElement("div")
    root.className = "flex items-center gap-3 px-4 py-3"

    const body = document.createElement("div")
    body.className = "min-w-0 flex-1"

    const left = document.createElement("div")
    left.className = "min-w-0 flex items-center gap-2"

    const filename = document.createElement("span")
    filename.className = "text-sm font-medium text-ink truncate"
    filename.textContent = name

    const status = document.createElement("span")
    status.className = "shrink-0 text-xs font-medium rounded-full px-2 py-0.5"

    left.appendChild(filename)
    left.appendChild(status)
    body.appendChild(left)
    root.appendChild(body)
    this.listTarget.appendChild(root)

    return { root, status }
  }

  updateSubmitState() {
    const hasQueued = this.entries.some((entry) => entry.status === "queued")
    this.submitTarget.disabled = this.uploading || !hasQueued
    this.submitTarget.textContent = this.uploading ? "Uploading..." : "Start upload"
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content
  }

  setRowStatus(row, state) {
    const statusConfig = {
      queued: { text: "Queued", classes: "text-ink-muted bg-canvas" },
      uploading: { text: "Uploading", classes: "text-primary bg-primary-soft" },
      failed: { text: "Failed", classes: "text-danger bg-[#FDECEA]" }
    }

    const config = statusConfig[state] || statusConfig.queued
    row.status.textContent = config.text
    row.status.className = `shrink-0 rounded-full px-2 py-0.5 text-xs font-medium ${config.classes}`
  }
}
