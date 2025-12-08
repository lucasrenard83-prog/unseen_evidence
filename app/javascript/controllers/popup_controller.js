import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="popup"
export default class extends Controller {
  static targets = ["imgpopup", "imgpopupimg", "itemfound"]
  connect() {
    const found = this.itemfoundTargets.filter(c => c.classList.contains("found"));
    found.forEach((container) => {
      const img = container.querySelector(".clue-image");

      container.addEventListener("click", (event) => {
        event.preventDefault();
        event.stopPropagation();
        this.imgpopupimgTarget.src = img.src;
        this.imgpopupTarget.style.display = "flex";
        this.imgpopupTarget.style.display = "flex";
      });
    });

    this.imgpopupTarget.addEventListener("click", () => {
      this.imgpopupTarget.style.display = "none";
      this.imgpopupimgTarget.src = "";
    });
  }

}
