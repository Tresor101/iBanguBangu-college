const form = document.getElementById("teacherForm");
const formMessage = document.getElementById("formMessage");
const password = document.getElementById("password");
const confirmPassword = document.getElementById("confirmPassword");

function validatePasswordMatch() {
  if (password.value !== confirmPassword.value) {
    confirmPassword.setCustomValidity("Passwords do not match");
  } else {
    confirmPassword.setCustomValidity("");
  }
}

[password, confirmPassword].forEach((input) => {
  input.addEventListener("input", () => {
    validatePasswordMatch();
    formMessage.classList.add("d-none");
  });
});

form.addEventListener("reset", () => {
  confirmPassword.setCustomValidity("");
  form.classList.remove("was-validated");
  formMessage.classList.add("d-none");
});

form.addEventListener("submit", (event) => {
  event.preventDefault();
  formMessage.classList.add("d-none");
  validatePasswordMatch();

  if (!form.checkValidity()) {
    form.classList.add("was-validated");
    formMessage.textContent = "Please fix the highlighted fields and try again.";
    formMessage.className = "alert alert-danger mt-3 mb-0";
    return;
  }

  formMessage.textContent = "Teacher registered successfully.";
  formMessage.className = "alert alert-success mt-3 mb-0";
  form.reset();
  form.classList.remove("was-validated");
});
