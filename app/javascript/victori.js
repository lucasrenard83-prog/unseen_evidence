document.addEventListener("turbo:load", () => {
const form = document.getElementById("form")
const weapon = document.getElementById("weapon")
const killer = document.getElementById("killer")
const room = document.getElementById("room")
const victory = document.getElementById("victory")
form.addEventListener("submit", (event) =>{
  const hasWin =
  room.value == "Greenhouse"&&
  weapon.value == "Kitchen knife"&&
  killer.value == "Mr. Rook";
  if (hasWin){
    event.preventDefault()
    victory.classList.remove("d-none")
  }
})
})
