import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="victori"
export default class extends Controller {
  static targets = ["weapon", "killer", "room", "victory"]
  connect() {
  }

  hasWin(event) {
    const hasWin =
      this.roomTarget.value == "Greenhouse"&&
      this.weaponTarget.value == "Kitchen knife"&&
      this.killerTarget.value == "Mr. Rook";
    if (hasWin){
      event.preventDefault()
      victory.classList.remove("d-none")
    }
  }
}
