const form = document.getElementById("classForm");
const formMessage = document.getElementById("formMessage");
const classCodeField = document.getElementById("classCode");
const classGradeField = document.getElementById("classGrade");
const sectionField = document.getElementById("section");
const requiredControls = form.querySelectorAll("input[required], select[required], textarea[required]");
const allControls = form.querySelectorAll("input, select, textarea");

function readRegisteredClasses() {
  try {
    const raw = localStorage.getItem("class-registrations");
    const parsed = raw ? JSON.parse(raw) : [];
    return Array.isArray(parsed) ? parsed : [];
  } catch (error) {
    return [];
  }
}

function writeRegisteredClasses(items) {
  localStorage.setItem("class-registrations", JSON.stringify(items));
}

function normalizeWords(value) {
  const words = (value || "")
    .trim()
    .toUpperCase()
    .match(/[A-Z0-9]+/g);

  return words || [];
}

function buildGradeToken(grade) {
  const words = normalizeWords(grade);
  if (words.length === 0) {
    return "00";
  }

  const gradeNumberToken = words.find((word) => /\d/.test(word)) || "";
  const gradeNumber = gradeNumberToken.replace(/\D/g, "").slice(0, 2);
  return gradeNumber || "00";
}

function buildSectionToken(section) {
  const words = normalizeWords(section);
  if (words.length === 0) {
    return "A";
  }
  return words.join("").slice(0, 1);
}

function generateClassCode() {
  const gradeToken = buildGradeToken(classGradeField.value);
  const sectionToken = buildSectionToken(sectionField.value);
  return `${gradeToken}${sectionToken}`;
}

function updateClassCodePreview() {
  classCodeField.value = generateClassCode();
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

function saveClassGrade() {
  const classCode = generateClassCode();
  const classGrade = classGradeField.value.trim();
  const section = sectionField.value.trim().toUpperCase();

  const classes = readRegisteredClasses();
  const duplicate = classes.some(
    (item) => String(item.classCode || "").toUpperCase() === classCode.toUpperCase()
  );

  if (duplicate) {
    setFieldInvalid(classGradeField, "This class code already exists.");
    updateClassCodePreview();
    return false;
  }

  classes.push({
    classCode,
    classGrade,
    section,
    createdAt: new Date().toISOString()
  });

  writeRegisteredClasses(classes);
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

classGradeField.addEventListener("input", updateClassCodePreview);
sectionField.addEventListener("input", updateClassCodePreview);

updateClassCodePreview();

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

  const saved = saveClassGrade();
  if (!saved) {
    form.classList.add("was-validated");
    formMessage.classList.remove("d-none");
    formMessage.classList.add("alert-danger");
    formMessage.textContent = "This class code already exists.";
    return;
  }

  formMessage.classList.remove("d-none");
  formMessage.classList.add("alert-success");
  formMessage.textContent = "Class/grade saved successfully.";
  form.reset();
  form.classList.remove("was-validated");
  allControls.forEach((control) => clearFieldValidation(control));
  updateClassCodePreview();
});
