const form = document.getElementById("teacherForm");
const formMessage = document.getElementById("formMessage");
const password = document.getElementById("password");
const confirmPassword = document.getElementById("confirmPassword");
const fullNameField = document.getElementById("fullName");
const phoneField = document.getElementById("phone");

function readRegisteredTeachers() {
  try {
    const raw = localStorage.getItem("teacher-registrations");
    const parsed = raw ? JSON.parse(raw) : [];
    return Array.isArray(parsed) ? parsed : [];
  } catch (error) {
    return [];
  }
}

function writeRegisteredTeachers(teachers) {
  localStorage.setItem("teacher-registrations", JSON.stringify(teachers));
}

function generateTeacherCode() {
  const now = new Date();
  const yearShort = String(now.getFullYear()).slice(-2);
  const storageKey = `teacher-id-counter-${yearShort}`;

  let nextCounter = 1;
  try {
    const storedCounter = Number(localStorage.getItem(storageKey) || "0");
    nextCounter = Number.isFinite(storedCounter) ? storedCounter + 1 : 1;
    localStorage.setItem(storageKey, String(nextCounter));
  } catch (error) {
    nextCounter = Math.floor(1 + Math.random() * 9999);
  }

  const paddedCounter = String(nextCounter).padStart(4, "0");
  return `TCH${yearShort}${paddedCounter}`;
}

function saveTeacherRegistration() {
  const fullName = fullNameField.value.trim();
  const phone = phoneField.value.trim();
  const teachers = readRegisteredTeachers();

  const duplicate = teachers.some(
    (item) =>
      String(item.fullName || "").toLowerCase() === fullName.toLowerCase() &&
      String(item.phone || "") === phone
  );

  if (duplicate) {
    return { ok: false, message: "This teacher is already registered." };
  }

  const teacherRecord = {
    teacherCode: generateTeacherCode(),
    fullName,
    phone,
    createdAt: new Date().toISOString()
  };

  teachers.push(teacherRecord);
  writeRegisteredTeachers(teachers);
  return { ok: true, teacherCode: teacherRecord.teacherCode };
}

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

  const saveResult = saveTeacherRegistration();
  if (!saveResult.ok) {
    formMessage.textContent = saveResult.message;
    formMessage.className = "alert alert-danger mt-3 mb-0";
    return;
  }

  formMessage.textContent = `Teacher registered successfully (${saveResult.teacherCode}).`;
  formMessage.className = "alert alert-success mt-3 mb-0";
  form.reset();
  form.classList.remove("was-validated");
});
