const form = document.getElementById("registrationForm");
const formMessage = document.getElementById("formMessage");
const studentIdField = document.getElementById("studentId");
const dobField = document.getElementById("dob");
const requiredControls = form.querySelectorAll("input[required], select[required]");
const allControls = form.querySelectorAll("input, select, textarea");

function generateStudentId() {
  const now = new Date();
  const yearShort = String(now.getFullYear()).slice(-2);
  const storageKey = `student-id-counter-${yearShort}`;

  let nextCounter = 1;
  try {
    const storedCounter = Number(localStorage.getItem(storageKey) || "0");
    nextCounter = Number.isFinite(storedCounter) ? storedCounter + 1 : 1;
    localStorage.setItem(storageKey, String(nextCounter));
  } catch (error) {
    // Fall back if localStorage is unavailable.
    nextCounter = Math.floor(1 + Math.random() * 9999);
  }

  const paddedCounter = String(nextCounter).padStart(4, "0");
  return `STU${yearShort}${paddedCounter}`;
}

function syncStudentIdentifiers() {
  const generatedId = generateStudentId();
  studentIdField.value = generatedId;
}

function formatDateForInput(date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

function setDobAllowedRange() {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const minDob = new Date(today);
  minDob.setFullYear(minDob.getFullYear() - 23);

  const maxDob = new Date(today);
  maxDob.setFullYear(maxDob.getFullYear() - 2);

  dobField.min = formatDateForInput(minDob);
  dobField.max = formatDateForInput(maxDob);
}

function getFieldLabel(control) {
  const label = form.querySelector(`label[for="${control.id}"]`);
  return label ? label.textContent.replace("(Optional)", "").trim() : "This field";
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

function normalizeIdentifier(value) {
  return value.trim().toUpperCase();
}

function readRegisteredStudents() {
  try {
    const raw = localStorage.getItem("student-registrations");
    const parsed = raw ? JSON.parse(raw) : [];
    return Array.isArray(parsed) ? parsed : [];
  } catch (error) {
    return [];
  }
}

function writeRegisteredStudents(students) {
  localStorage.setItem("student-registrations", JSON.stringify(students));
}

function saveStudentRegistration() {
  const parentIdControl = document.getElementById("parentId");
  const parentId = normalizeIdentifier(parentIdControl.value);
  parentIdControl.value = parentId;

  const studentRecord = {
    studentId: studentIdField.value,
    parentId,
    fullName: document.getElementById("fullName").value.trim(),
    grade: document.getElementById("grade").value.trim(),
    gender: document.getElementById("gender").value,
    dateOfBirth: dobField.value,
    createdAt: new Date().toISOString()
  };

  const registrations = readRegisteredStudents();
  const existingIndex = registrations.findIndex((item) => item.studentId === studentRecord.studentId);

  if (existingIndex >= 0) {
    registrations[existingIndex] = studentRecord;
  } else {
    registrations.push(studentRecord);
  }

  writeRegisteredStudents(registrations);
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

syncStudentIdentifiers();
setDobAllowedRange();

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

  const dobValue = dobField.value;
  const [dobYear, dobMonth, dobDay] = dobValue.split("-").map(Number);

  const dobDate = new Date(dobYear, dobMonth - 1, dobDay);
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const oldestAllowedDob = new Date(today);
  oldestAllowedDob.setFullYear(oldestAllowedDob.getFullYear() - 23);

  const youngestAllowedDob = new Date(today);
  youngestAllowedDob.setFullYear(youngestAllowedDob.getFullYear() - 2);

  if (dobDate < oldestAllowedDob || dobDate > youngestAllowedDob) {
    setFieldInvalid(dobField, "Student age must be between 2 and 23 years.");
    form.classList.add("was-validated");
    formMessage.classList.remove("d-none");
    formMessage.classList.add("alert-danger");
    formMessage.textContent = "Student age must be between 2 and 23 years.";
    return;
  }

  saveStudentRegistration();

  formMessage.classList.remove("d-none");
  formMessage.classList.add("alert-success");
  formMessage.textContent = "Student registration submitted successfully.";
  form.reset();
  form.classList.remove("was-validated");
  allControls.forEach((control) => clearFieldValidation(control));
  syncStudentIdentifiers();
});
