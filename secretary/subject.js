const form = document.getElementById("subjectForm");
const formMessage = document.getElementById("formMessage");
const subjectCodeField = document.getElementById("subjectCode");
const subjectNameField = document.getElementById("subjectName");
const classCodeField = document.getElementById("classCode");
const gradeLevelField = document.getElementById("gradeLevel");
const departmentField = document.getElementById("departmentId");
const requiredControls = form.querySelectorAll("input[required], select[required], textarea[required]");
const allControls = form.querySelectorAll("input, select, textarea");

function buildSubjectToken(subjectName) {
  const words = subjectName
    .trim()
    .toUpperCase()
    .match(/[A-Z0-9]+/g);

  if (!words || words.length === 0) {
    return "SUBJ";
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

function buildGradeToken(gradeLevel) {
  const normalized = normalizeGradeLevel(gradeLevel);
  const tokens = normalized.match(/[A-Z0-9]+/g) || [];

  if (tokens.length === 0) {
    return "00GEN";
  }

  const ignoredWords = new Set(["GRADE", "CLASS", "FORM", "YEAR"]);
  const meaningful = tokens.filter((token) => !ignoredWords.has(token));

  const gradeToken = meaningful.find((token) => /\d/.test(token)) || "";
  const gradeNumber = gradeToken.replace(/\D/g, "").slice(0, 2);

  const streamToken = meaningful.find(
    (token) => /^[A-Z]+$/.test(token) && token.length > 1
  ) || "";
  const streamCode = streamToken.slice(0, 3);

  if (gradeNumber && streamCode) {
    return `${gradeNumber}${streamCode}`;
  }

  if (gradeNumber) {
    return gradeNumber;
  }

  if (streamCode) {
    return streamCode;
  }

  return meaningful.join("").slice(0, 5) || "GEN";
}

function normalizeGradeLevel(gradeLevel) {
  const tokens = (gradeLevel || "")
    .trim()
    .toUpperCase()
    .match(/[A-Z0-9]+/g);

  if (!tokens || tokens.length === 0) {
    return "";
  }

  const normalizedTokens = [...tokens];
  const lastToken = normalizedTokens[normalizedTokens.length - 1];

  // Ignore section suffixes like A/B/C so Commerce A/B/C map to the same grade token.
  if (/^[A-Z]$/.test(lastToken)) {
    normalizedTokens.pop();
  }

  const compact = normalizedTokens.join(" ").trim();
  if (!compact) {
    return "";
  }

  return compact;
}

function generateSubjectCode() {
  const subjectToken = buildSubjectToken(subjectNameField.value);
  const gradeToken = buildGradeToken(gradeLevelField.value);
  return `${subjectToken}${gradeToken}`;
}

function updateSubjectCodePreview() {
  subjectCodeField.value = generateSubjectCode();
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

function readRegisteredSubjects() {
  try {
    const raw = localStorage.getItem("subject-registrations");
    const parsed = raw ? JSON.parse(raw) : [];
    return Array.isArray(parsed) ? parsed : [];
  } catch (error) {
    return [];
  }
}

function writeRegisteredSubjects(subjects) {
  localStorage.setItem("subject-registrations", JSON.stringify(subjects));
}

function readRegisteredClasses() {
  try {
    const raw = localStorage.getItem("class-registrations");
    const parsed = raw ? JSON.parse(raw) : [];
    return Array.isArray(parsed) ? parsed : [];
  } catch (error) {
    return [];
  }
}

function readRegisteredDepartments() {
  try {
    const raw = localStorage.getItem("department-registrations");
    const parsed = raw ? JSON.parse(raw) : [];
    return Array.isArray(parsed) ? parsed : [];
  } catch (error) {
    return [];
  }
}

function getDepartmentById(departmentId) {
  const departments = readRegisteredDepartments();
  return departments.find(
    (item) => Number(item.departmentId || item.id || 0) === Number(departmentId)
  ) || null;
}

function getClassByCode(classCode) {
  const classes = readRegisteredClasses();
  return classes.find(
    (item) => String(item.classCode || item.class_code || "").toUpperCase() === String(classCode || "").toUpperCase()
  ) || null;
}

function populateClassOptions() {
  const classes = readRegisteredClasses();
  const currentValue = classCodeField.value;

  classCodeField.innerHTML = "";

  const placeholder = document.createElement("option");
  placeholder.value = "";
  placeholder.textContent = "Select class code";
  placeholder.disabled = true;
  placeholder.selected = true;
  classCodeField.appendChild(placeholder);

  classes
    .slice()
    .sort((a, b) => String(a.classCode || "").localeCompare(String(b.classCode || "")))
    .forEach((classItem) => {
      const classCode = String(classItem.classCode || classItem.class_code || "").trim();
      if (!classCode) {
        return;
      }

      const gradeLabel = String(classItem.classGrade || classItem.class_grade || "").trim();
      const sectionLabel = String(classItem.section || "").trim();
      const classLabel = sectionLabel ? `${gradeLabel} ${sectionLabel}` : gradeLabel;

      const option = document.createElement("option");
      option.value = classCode;
      option.textContent = classLabel ? `${classCode} - ${classLabel}` : classCode;
      classCodeField.appendChild(option);
    });

  if (currentValue) {
    classCodeField.value = currentValue;
  }
}

function syncGradeLevelFromClassCode() {
  const selectedClass = getClassByCode(classCodeField.value);
  if (!selectedClass) {
    gradeLevelField.value = "";
    updateSubjectCodePreview();
    return;
  }

  const gradeLabel = String(selectedClass.classGrade || selectedClass.class_grade || "").trim();
  const sectionLabel = String(selectedClass.section || "").trim();
  gradeLevelField.value = sectionLabel ? `${gradeLabel} ${sectionLabel}`.trim() : gradeLabel;
  updateSubjectCodePreview();
}

function populateDepartmentOptions() {
  const departments = readRegisteredDepartments();
  const currentValue = departmentField.value;

  departmentField.innerHTML = "";

  const placeholder = document.createElement("option");
  placeholder.value = "";
  placeholder.textContent = "Select department";
  placeholder.disabled = true;
  placeholder.selected = true;
  departmentField.appendChild(placeholder);

  departments
    .slice()
    .sort((a, b) => String(a.departmentName || "").localeCompare(String(b.departmentName || "")))
    .forEach((department) => {
      const option = document.createElement("option");
      const departmentId = Number(department.departmentId || department.id || 0);
      if (!Number.isFinite(departmentId) || departmentId <= 0) {
        return;
      }

      option.value = String(departmentId);
      option.textContent = `${department.departmentName} (${department.departmentCode})`;
      departmentField.appendChild(option);
    });

  if (currentValue) {
    departmentField.value = currentValue;
  }
}

function saveSubject() {
  const subjectName = document.getElementById("subjectName").value.trim();
  const classCode = classCodeField.value.trim().toUpperCase();
  const selectedClass = getClassByCode(classCode);
  if (!selectedClass) {
    setFieldInvalid(classCodeField, "Please select a valid class code.");
    return false;
  }

  const gradeLevel = document.getElementById("gradeLevel").value.trim();
  const normalizedGradeLevel = normalizeGradeLevel(gradeLevel);
  const generatedCode = generateSubjectCode();
  const departmentId = Number(departmentField.value);
  const department = getDepartmentById(departmentId);
  const maximumMarkControl = document.getElementById("maximumMark");
  const maximumMark = Number(maximumMarkControl.value);

  if (!department) {
    setFieldInvalid(departmentField, "Please select a valid department.");
    return false;
  }

  if (!Number.isFinite(maximumMark) || maximumMark < 1) {
    setFieldInvalid(maximumMarkControl, "Maximum mark must be at least 1.");
    return false;
  }

  const subjectRecord = {
    subjectCode: generatedCode,
    subjectName,
    classCode,
    class_code: classCode,
    classId: Number(selectedClass.classId || selectedClass.id || 0) || null,
    class_id: Number(selectedClass.classId || selectedClass.id || 0) || null,
    gradeLevel,
    grade_level: gradeLevel,
    departmentId,
    department_id: departmentId,
    departmentCode: department.departmentCode,
    departmentName: department.departmentName,
    maximumMark,
    maximum_mark: maximumMark,
    createdAt: new Date().toISOString()
  };

  const subjects = readRegisteredSubjects();
  const duplicate = subjects.some(
    (item) =>
      item.subjectName.toLowerCase() === subjectName.toLowerCase() &&
      String(item.classCode || item.class_code || "").toUpperCase() === classCode &&
      normalizeGradeLevel(item.gradeLevel || item.grade_level || "").toLowerCase() === normalizedGradeLevel.toLowerCase() &&
      Number(item.departmentId || item.department_id || 0) === departmentId
  );
  const duplicateCode = subjects.some(
    (item) => String(item.subjectCode || "").toUpperCase() === generatedCode.toUpperCase()
  );

  if (duplicate || duplicateCode) {
    setFieldInvalid(
      document.getElementById("subjectName"),
      duplicate
        ? "This subject is already registered for the selected grade/class."
        : "This subject code already exists. Adjust the subject name or grade/class."
    );
    subjectCodeField.value = generatedCode;
    return false;
  }

  subjects.push(subjectRecord);
  writeRegisteredSubjects(subjects);
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

subjectNameField.addEventListener("input", updateSubjectCodePreview);
classCodeField.addEventListener("change", () => {
  clearFieldValidation(classCodeField);
  syncGradeLevelFromClassCode();
});

populateClassOptions();
syncGradeLevelFromClassCode();
populateDepartmentOptions();

updateSubjectCodePreview();

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

  const saved = saveSubject();
  if (!saved) {
    form.classList.add("was-validated");
    formMessage.classList.remove("d-none");
    formMessage.classList.add("alert-danger");
    formMessage.textContent = "Duplicate subject for this class is not allowed.";
    return;
  }

  formMessage.classList.remove("d-none");
  formMessage.classList.add("alert-success");
  formMessage.textContent = "Subject saved successfully.";
  form.reset();
  populateClassOptions();
  syncGradeLevelFromClassCode();
  populateDepartmentOptions();
  form.classList.remove("was-validated");
  allControls.forEach((control) => clearFieldValidation(control));
  updateSubjectCodePreview();
});
