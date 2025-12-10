import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  play(event) {
    event.preventDefault()

    const button = event.currentTarget
    const url = button.dataset.ttsUrlValue || this.urlValue
    if (!url) return

    if (button.audio) {
      button.audio.currentTime = 0
      button.audio.play()
      return
    }

    fetch(url)
      .then(response => {
        if (!response.ok) throw new Error("TTS request failed")
        return response.blob()
      })
      .then(blob => {
        const audioUrl = URL.createObjectURL(blob)
        const audio = new Audio(audioUrl)
        button.audio = audio
        audio.play()
      })
      .catch(error => {
        console.error(error)
      })
  }
}
