renderAcademicDirectorNavbar();

const REGISTERED_ROLE = "Deputy Academic Director";
const form = document.getElementById("deputyAcademicForm");
const password = document.getElementById("password");
const confirmPassword = document.getElementById("confirmPassword");
const fullName = document.getElementById("fullName");
const phone = document.getElementById("phone");
const formMessage = document.getElementById("formMessage");

function resetMessage() {
  formMessage.classList.add("d-none");
  formMessage.classList.remove("alert-danger", "alert-success");
  formMessage.textContent = "";
}

function validatePasswordMatch() {
  if (password.value !== confirmPassword.value) {
    confirmPassword.setCustomValidity("Passwords do not match");
  } else {
    confirmPassword.setCustomValidity("");
  }
}

[password, confirmPassword, fullName, phone].forEach((input) => {
  input.addEventListener("input", () => {
    validatePasswordMatch();
    resetMessage();
  });
});

form.addEventListener("reset", () => {
  confirmPassword.setCustomValidity("");
  form.classList.remove("was-validated");
  resetMessage();
});

form.addEventListener("submit", (event) => {
  event.preventDefault();

  fullName.value = fullName.value.trim().replace(/\s+/g, " ");
  phone.value = phone.value.trim();
  validatePasswordMatch();

  if (!form.checkValidity()) {
    form.classList.add("was-validated");
    formMessage.textContent = "Please fix the highlighted fields and try again.";
    formMessage.classList.remove("d-none", "alert-success");
    formMessage.classList.add("alert-danger");
    return;
  }

  formMessage.textContent = REGISTERED_ROLE + " registered successfully.";
  formMessage.classList.remove("d-none", "alert-danger");
  formMessage.classList.add("alert-success");
  form.reset();
  form.classList.remove("was-validated");
});
