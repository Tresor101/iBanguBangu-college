const form = document.getElementById("departmentForm");
const formMessage = document.getElementById("formMessage");
const departmentCodeField = document.getElementById("departmentCode");
const departmentNameField = document.getElementById("departmentName");
const requiredControls = form.querySelectorAll("input[required], select[required], textarea[required]");
const allControls = form.querySelectorAll("input, select, textarea");

function readRegisteredDepartments() {
  try {
    const raw = localStorage.getItem("department-registrations");
    const parsed = raw ? JSON.parse(raw) : [];
    return Array.isArray(parsed) ? parsed : [];
  } catch (error) {
    return [];
  }
}

function writeRegisteredDepartments(departments) {
  localStorage.setItem("department-registrations", JSON.stringify(departments));
}

function getNextDepartmentId() {
  const departments = readRegisteredDepartments();
  const maxId = departments.reduce((max, item) => {
    const currentId = Number(item.departmentId || item.id || 0);
    return Number.isFinite(currentId) ? Math.max(max, currentId) : max;
  }, 0);

  return maxId + 1;
}

function generateDepartmentCode() {
  const words = departmentNameField.value
    .trim()
    .toUpperCase()
    .match(/[A-Z0-9]+/g);

  if (!words || words.length === 0) {
    return "DEPT";
  }

  if (words.length === 1) {
    return words[0].slice(0, 4).padEnd(3, "X");
  }

  return words
    .map((word) => word[0])
    .join("")
    .slice(0, 4)
    .padEnd(3, "X");
}

function getFieldLabel(control) {
  const label = form.querySelector(`label[for="${control.id}"]`);
  return label ? label.textContent.trim() : "This field";
}

function ensureInvalidFeedback(control) {
  const container = control.closest(".form-check") || control.parentElement;
  const existing = container.querySelector(".invalid-feedback[data-for='" + control.id + "']");
  if (existing) {
    return existing;
  }

  const feedback = document.createElement("div");
  feedback.className = "invalid-feedback";
  feedback.dataset.for = control.id;
  feedback.textContent = `${getFieldLabel(control)} is required.`;
  container.appendChild(feedback);
  return feedback;
}

function setFieldInvalid(control, message) {
  const feedback = ensureInvalidFeedback(control);
  control.setCustomValidity(message);
  feedback.textContent = message;
  control.classList.add("is-invalid");
}

function clearFieldValidation(control) {
  control.setCustomValidity("");
  control.classList.remove("is-invalid");
}

function updateDepartmentCodePreview() {
  departmentCodeField.value = generateDepartmentCode();
}

function saveDepartment() {
  const departmentName = departmentNameField.value.trim();
  const departmentCode = generateDepartmentCode();
  const departments = readRegisteredDepartments();

  const duplicateName = departments.some(
    (item) => String(item.departmentName || "").toLowerCase() === departmentName.toLowerCase()
  );

  const duplicateCode = departments.some(
    (item) => String(item.departmentCode || "").toUpperCase() === departmentCode.toUpperCase()
  );

  if (duplicateName || duplicateCode) {
    setFieldInvalid(
      departmentNameField,
      duplicateName
        ? "This department name already exists."
        : "This department code already exists."
    );
    updateDepartmentCodePreview();
    return false;
  }

  departments.push({
    departmentId: getNextDepartmentId(),
    departmentCode,
    departmentName,
    createdAt: new Date().toISOString()
  });

  writeRegisteredDepartments(departments);
  return true;
}

requiredControls.forEach((control) => {
  ensureInvalidFeedback(control);
  control.addEventListener("input", () => {
    clearFieldValidation(control);
  });
  control.addEventListener("change", () => {
    clearFieldValidation(control);
  });
});

departmentNameField.addEventListener("input", updateDepartmentCodePreview);
updateDepartmentCodePreview();

form.addEventListener("submit", (event) => {
  event.preventDefault();
  formMessage.className = "alert mt-3 d-none";
  formMessage.textContent = "";
  allControls.forEach((control) => clearFieldValidation(control));

  if (!form.checkValidity()) {
    form.classList.add("was-validated");
    formMessage.classList.remove("d-none");
    formMessage.classList.add("alert-danger");
    formMessage.textContent = "Please fix the highlighted fields and try again.";
    return;
  }

  const saved = saveDepartment();
  if (!saved) {
    form.classList.add("was-validated");
    formMessage.classList.remove("d-none");
    formMessage.classList.add("alert-danger");
    formMessage.textContent = "This department already exists.";
    return;
  }

  formMessage.classList.remove("d-none");
  formMessage.classList.add("alert-success");
  formMessage.textContent = "Department saved successfully.";
  form.reset();
  form.classList.remove("was-validated");
  allControls.forEach((control) => clearFieldValidation(control));
  updateDepartmentCodePreview();
});
