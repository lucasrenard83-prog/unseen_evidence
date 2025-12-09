import dayjs from 'dayjs'
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="timer"
export default class extends Controller {
  static targets = ["clock", "fiveMinutesToast"]
  static values = {
    url: String,
    counter: Number,
    gameId: Number,
    rul: String
  }

  connect() {
    const fromServer = this.counterValue || 3599
    const stored = localStorage.getItem(this.storageKey);
    const fromLocal = stored ? Number(stored) : 3599;

    this.counterValue = Math.min(fromServer, fromLocal);
    this.updateClock();

    this.intervalId = setInterval(() => {
      if (this.counterValue > 0) {
        this.counterValue -= 1
        localStorage.setItem(this.storageKey, this.counterValue)
        this.updateClock()

        if (this.counterValue === 300 && this.hasFiveMinutesToastTarget) {
          this.fiveMinutesToastTarget.classList.add("show")
          setTimeout(() => {
          this.fiveMinutesToastTarget.classList.add("hide")
        }, 5000)
        }
          if(this.counterValue<=10 && this.counterValue> 0) {
            this.clockTarget.classList.add("timer-pulse")
          } else {
            this.clockTarget.classList.remove("timer-pulse")
          }
      } else {
        clearInterval(this.intervalId)
        window.location.href =`/games/${this.gameIdValue}/confrontation`;

      }
    }, 1000);
    }


  disconnect(){
    clearInterval(this.intervalId)

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ game: { elapsed_time: this.counterValue } }),
      keepalive: true
    })
  }

    updateClock() {
    this.clockTarget.innerText = dayjs(this.counterValue * 1000).format('mm:ss');
  }
    get storageKey() {
    return `timer-counter-${this.gameIdValue}`;
  }

  goToConfrontation(event) {
  event.preventDefault();
  clearInterval(this.intervalId);
  console.log(this.counterValue);

  fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ game: { elapsed_time: this.counterValue } }),
      keepalive: true
    })
    .then(() => {
      window.location.href = `/games/${this.gameIdValue}/confrontation`;
    });
  };
}
