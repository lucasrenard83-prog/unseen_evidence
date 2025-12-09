import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "button"]

  connect() {
    this.recognition = null
    this.isListening = false
    this.supported = ('webkitSpeechRecognition' in window) || ('SpeechRecognition' in window)

    if (!this.supported) {
      this.buttonTarget.style.display = 'none'
    }
  }

  toggle() {
    if (!this.supported) return
    this.isListening ? this.stop() : this.start()
  }

  start() {
    if (this.isListening) return

    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
    this.recognition = new SpeechRecognition()
    this.recognition.lang = 'en-US';
    this.recognition.continuous = true
    this.recognition.interimResults = true

    this.recognition.onresult = (event) => {
      let finalTranscript = ''
      for (let i = event.resultIndex; i < event.results.length; i++) {
        finalTranscript += event.results[i][0].transcript
      }
      this.inputTarget.value = finalTranscript
    }

    this.recognition.onerror = (event) => {
      if (event.error !== 'aborted' && event.error !== 'no-speech') {
        console.warn('Speech recognition error:', event.error)
      }
    }

    this.recognition.onend = () => {
      // Redémarrer automatiquement si toujours en mode écoute
      if (this.isListening) {
        this.recognition.start()
      }
    }

    try {
      this.recognition.start()
      this.isListening = true
      this.buttonTarget.classList.add('recording')
    } catch (e) {
      console.warn('Speech recognition start failed:', e)
      this.resetState()
    }
  }

  stop() {
    this.isListening = false
    if (this.recognition) {
      this.recognition.onend = null
      this.recognition.stop()
      this.recognition = null
    }
    this.buttonTarget.classList.remove('recording')
  }

  resetState() {
    this.isListening = false
    this.buttonTarget.classList.remove('recording')
    if (this.recognition) {
      this.recognition.onend = null
      this.recognition = null
    }
  }
}
