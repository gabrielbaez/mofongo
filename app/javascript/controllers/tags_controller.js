import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String
  }

  connect() {
    this.initializeTagSelect()
  }

  initializeTagSelect() {
    new TomSelect(this.element, {
      persist: false,
      createOnBlur: true,
      create: true,
      valueField: 'name',
      labelField: 'name',
      searchField: 'name',
      delimiter: ',',
      load: async (query, callback) => {
        if (!query.length) return callback()

        try {
          const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`)
          const data = await response.json()
          callback(data)
        } catch (error) {
          console.error("Error loading tags:", error)
          callback()
        }
      }
    })
  }
}
