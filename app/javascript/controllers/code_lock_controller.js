import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="code-lock"
export default class extends Controller {
  static targets = ["modal", "dot", "lockIcon", "errorMessage", "successMessage"]
  static values = {
    code: String,
    roomId: Number
  }

  connect() {
    this.currentCode = '';
    this.setupKeyboardListener();
    // Show the modal immediately when controller connects (it's created when trapdoor is found)
    this.element.style.display = 'flex';
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleKeydown);
  }

  setupKeyboardListener() {
    this.handleKeydown = (e) => {
      // Check if modal wrapper is visible
      const isVisible = this.element.style.display !== 'none';
      if (isVisible) {
        if (e.key >= '0' && e.key <= '9') {
          this.addDigit(parseInt(e.key));
        } else if (e.key === 'Enter') {
          this.submitCode();
        } else if (e.key === 'Backspace' || e.key === 'Delete') {
          this.clearCode();
        } else if (e.key === 'Escape') {
          this.close();
        }
      }
    };
    document.addEventListener('keydown', this.handleKeydown);
  }

  close() {
    this.element.style.display = 'none';
  }

  addDigit(digit) {
    if (typeof digit === 'object') {
      digit = parseInt(digit.currentTarget.dataset.digit);
    }
    if (this.currentCode.length < 4) {
      this.currentCode += digit;
      this.updateDisplay();
    }
  }

  clearCode() {
    this.currentCode = '';
    this.updateDisplay();
    this.hideMessages();
  }

  updateDisplay() {
    this.dotTargets.forEach((dot, index) => {
      const span = dot.querySelector('span');
      if (index < this.currentCode.length) {
        span.textContent = this.currentCode[index];
        dot.classList.add('filled');
      } else {
        span.textContent = '';
        dot.classList.remove('filled');
      }
    });
  }

  submitCode() {
    if (this.currentCode.length !== 4) {
      this.showError('Please enter 4 digits');
      return;
    }

    if (this.currentCode === this.codeValue) {
      // Code correct
      this.lockIconTarget.classList.add('unlocked');
      this.successMessageTarget.classList.remove('d-none');
      this.errorMessageTarget.classList.add('d-none');

      // Call the server to mark Kitchen knife as found
      this.unlockTrapdoor();
    } else {
      // Code incorrect
      this.lockIconTarget.classList.add('shake');
      this.errorMessageTarget.classList.remove('d-none');
      this.successMessageTarget.classList.add('d-none');

      setTimeout(() => {
        this.lockIconTarget.classList.remove('shake');
        this.clearCode();
      }, 500);
    }
  }

  async unlockTrapdoor() {
    try {
      const response = await fetch(`/rooms/${this.roomIdValue}/unlock_trapdoor`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      });

      if (response.ok) {
        setTimeout(() => {
          this.close();
          // Reload to show the found item
          window.location.reload();
        }, 1500);
      }
    } catch (error) {
      console.error('Error unlocking trapdoor:', error);
    }
  }

  showError(message) {
    this.errorMessageTarget.textContent = message;
    this.errorMessageTarget.classList.remove('d-none');

    setTimeout(() => {
      this.errorMessageTarget.classList.add('d-none');
    }, 2000);
  }

  hideMessages() {
    this.errorMessageTarget.classList.add('d-none');
    this.successMessageTarget.classList.add('d-none');
  }

  resetModal() {
    this.clearCode();
    this.lockIconTarget.classList.remove('unlocked', 'shake');
    this.hideMessages();
  }

  // Close modal when clicking on backdrop
  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close();
    }
  }
}
