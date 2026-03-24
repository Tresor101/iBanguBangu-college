const form = document.getElementById("parentForm");
const formMessage = document.getElementById("formMessage");

form.addEventListener("submit", (event) => {
  event.preventDefault();
  formMessage.classList.add("d-none");

  if (!form.checkValidity()) {
    form.classList.add("was-validated");
    formMessage.textContent = "Please fix the highlighted fields and try again.";
    formMessage.className = "alert alert-danger mt-3 mb-0";
    return;
  }

  formMessage.textContent = "Parent registered successfully.";
  formMessage.className = "alert alert-success mt-3 mb-0";
  form.reset();
  form.classList.remove("was-validated");
});
