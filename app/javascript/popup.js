function ImagePopup() {
  const popup    = document.getElementById("img-popup");
  const popupImg = document.getElementById("img-popup-img");
  const containers = document.querySelectorAll(".clue-container.found");

  containers.forEach((container) => {
    const img = container.querySelector(".clue-image");

    container.addEventListener("click", (event) => {
      event.preventDefault();
      event.stopPropagation();
      popupImg.src = img.src;
      popup.style.display = "flex";
      popup.style.display = "flex";
    });
  });

  popup.addEventListener("click", () => {
    popup.style.display = "none";
    popupImg.src = "";
  });
}

document.addEventListener("turbo:load", ImagePopup);
