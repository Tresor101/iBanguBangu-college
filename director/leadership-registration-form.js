renderDashboardNavbar({ mountId: "appNavbar", active: "proprietor" });

const leadershipForm = document.getElementById("leadershipForm");
const formMessage = document.getElementById("formMessage");
const roleInput = document.getElementById("role");
const fullNameInput = document.getElementById("fullName");
const phoneInput = document.getElementById("phone");
const emergencyContactInput = document.getElementById("emergencyContact");
const passwordInput = document.getElementById("password");
const confirmPasswordInput = document.getElementById("confirmPassword");
const passwordStrengthBar = document.getElementById("passwordStrengthBar");
const passwordStrengthText = document.getElementById("passwordStrengthText");

function setRoleFromQueryParam() {
  const params = new URLSearchParams(window.location.search);
  const role = params.get("role");
  if (!role) {
    return;
  }

  const normalizedRole = role.trim().toLowerCase();
  const option = Array.from(roleInput.options).find((item) => item.value.trim().toLowerCase() === normalizedRole);
  if (option) {
    roleInput.value = option.value;
  }
}

function resetFormMessage() {
  formMessage.classList.add("d-none");
  formMessage.classList.remove("alert-danger", "alert-success");
  formMessage.textContent = "";
}

function validatePasswordMatch() {
  if (passwordInput.value !== confirmPasswordInput.value) {
    confirmPasswordInput.setCustomValidity("Passwords do not match");
  } else {
    confirmPasswordInput.setCustomValidity("");
  }
}

function normalizeTextInput(input) {
  input.value = input.value.trim().replace(/\s+/g, " ");
}

function updatePasswordStrength() {
  const value = passwordInput.value;
  let score = 0;

  if (value.length >= 6) {
    score += 1;
  }
  if (value.length >= 10) {
    score += 1;
  }
  if (/[A-Z]/.test(value)) {
    score += 1;
  }
  if (/[a-z]/.test(value)) {
    score += 1;
  }
  if (/\d/.test(value)) {
    score += 1;
  }
  if (/[^A-Za-z0-9]/.test(value)) {
    score += 1;
  }

  passwordStrengthBar.classList.remove("strength-weak", "strength-medium", "strength-strong");

  if (value.length === 0) {
    passwordStrengthBar.style.width = "0";
    passwordStrengthText.textContent = "Strength: Too short";
    return;
  }

  if (value.length < 6 || score <= 2) {
    passwordStrengthBar.style.width = "33%";
    passwordStrengthBar.classList.add("strength-weak");
    passwordStrengthText.textContent = "Strength: Weak";
    return;
  }

  if (score <= 4) {
    passwordStrengthBar.style.width = "66%";
    passwordStrengthBar.classList.add("strength-medium");
    passwordStrengthText.textContent = "Strength: Medium";
    return;
  }

  passwordStrengthBar.style.width = "100%";
  passwordStrengthBar.classList.add("strength-strong");
  passwordStrengthText.textContent = "Strength: Strong";
}

[roleInput, fullNameInput, phoneInput, emergencyContactInput, passwordInput, confirmPasswordInput].forEach((input) => {
  input.addEventListener("input", () => {
    if (input === passwordInput || input === confirmPasswordInput) {
      validatePasswordMatch();
      updatePasswordStrength();
    }
    resetFormMessage();
  });
});

leadershipForm.addEventListener("reset", () => {
  confirmPasswordInput.setCustomValidity("");
  updatePasswordStrength();
  leadershipForm.classList.remove("was-validated");
  resetFormMessage();
});

leadershipForm.addEventListener("submit", (event) => {
  event.preventDefault();

  normalizeTextInput(fullNameInput);
  normalizeTextInput(phoneInput);
  normalizeTextInput(emergencyContactInput);
  validatePasswordMatch();

  if (!leadershipForm.checkValidity()) {
    leadershipForm.classList.add("was-validated");
    formMessage.textContent = "Please fix the form errors and try again.";
    formMessage.classList.remove("d-none", "alert-success");
    formMessage.classList.add("alert-danger");
    return;
  }

  const role = roleInput.value;
  const name = fullNameInput.value;

  formMessage.textContent = role + " " + name + " registered successfully.";
  formMessage.classList.remove("d-none", "alert-danger");
  formMessage.classList.add("alert-success");
  leadershipForm.reset();
  updatePasswordStrength();
  leadershipForm.classList.remove("was-validated");
});

updatePasswordStrength();
setRoleFromQueryParam();
