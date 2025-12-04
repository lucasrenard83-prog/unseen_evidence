function ImagePopup() {
  const popup    = document.getElementById("img-popup");
  const popupImg = document.getElementById("img-popup-img");
  const images   = document.querySelectorAll(".clue-image.found");
  images.forEach((img) => {
    img.addEventListener("click", () => {
      console.log("coucoucoucoucou");

      popupImg.src = img.src;
      popup.style.display = "flex";
    });
  });

  popup.addEventListener("click", () => {
    popup.style.display = "none";
    popupImg.src = "";
  });
}
document.addEventListener("turbo:load", ImagePopup);
