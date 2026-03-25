const assignmentForm = document.getElementById("assignmentForm");
const assignClassCodeField = document.getElementById("assignClassCode");
const assignSubjectCodeField = document.getElementById("assignSubjectCode");
const assignDepartmentField = document.getElementById("assignDepartment");
const assignTeacherCodeField = document.getElementById("assignTeacherCode");
const assignmentMessage = document.getElementById("assignmentMessage");
const assignmentTableBody = document.getElementById("assignmentTableBody");
const assignmentEmptyState = document.getElementById("assignmentEmptyState");

function readRegisteredClasses() {
  try {
    const raw = localStorage.getItem("class-registrations");
    const parsed = raw ? JSON.parse(raw) : [];
    return Array.isArray(parsed) ? parsed : [];
  } catch (error) {
    return [];
  }
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

function readRegisteredTeachers() {
  try {
    const raw = localStorage.getItem("teacher-registrations");
    const parsed = raw ? JSON.parse(raw) : [];
    return Array.isArray(parsed) ? parsed : [];
  } catch (error) {
    return [];
  }
}

function readClassAssignments() {
  try {
    const raw = localStorage.getItem("class-assignments");
    const parsed = raw ? JSON.parse(raw) : [];
    return Array.isArray(parsed) ? parsed : [];
  } catch (error) {
    return [];
  }
}

function writeClassAssignments(assignments) {
  localStorage.setItem("class-assignments", JSON.stringify(assignments));
}

function showAssignmentMessage(type, message) {
  assignmentMessage.className = `alert alert-${type} mb-0`;
  assignmentMessage.textContent = message;
}

function clearAssignmentMessage() {
  assignmentMessage.className = "alert d-none mb-0";
  assignmentMessage.textContent = "";
}

function populateClassOptions() {
  const classes = readRegisteredClasses()
    .slice()
    .sort((a, b) => String(a.classCode || "").localeCompare(String(b.classCode || "")));

  const selectedClassCode = assignClassCodeField.value;

  assignClassCodeField.innerHTML = "";
  const placeholder = document.createElement("option");
  placeholder.value = "";
  placeholder.textContent = "Select class code";
  placeholder.disabled = true;
  placeholder.selected = true;
  assignClassCodeField.appendChild(placeholder);

  classes.forEach((item) => {
    const classCode = String(item.classCode || item.class_code || "");
    const grade = String(item.classGrade || item.class_grade || "");
    const section = String(item.section || "");

    if (!classCode) {
      return;
    }

    const option = document.createElement("option");
    option.value = classCode;
    option.textContent = `${classCode} - ${grade}${section ? ` ${section}` : ""}`;
    assignClassCodeField.appendChild(option);
  });

  if (selectedClassCode) {
    assignClassCodeField.value = selectedClassCode;
  }
}

function populateTeacherOptions() {
  const teachers = readRegisteredTeachers()
    .slice()
    .sort((a, b) => String(a.fullName || "").localeCompare(String(b.fullName || "")));

  const selectedTeacherCode = assignTeacherCodeField.value;

  assignTeacherCodeField.innerHTML = "";
  const placeholder = document.createElement("option");
  placeholder.value = "";
  placeholder.textContent = "Select teacher";
  placeholder.disabled = true;
  placeholder.selected = true;
  assignTeacherCodeField.appendChild(placeholder);

  teachers.forEach((teacher) => {
    const teacherCode = String(teacher.teacherCode || "").trim();
    const fullName = String(teacher.fullName || "").trim();
    if (!teacherCode || !fullName) {
      return;
    }

    const option = document.createElement("option");
    option.value = teacherCode;
    option.textContent = `${fullName} (${teacherCode})`;
    assignTeacherCodeField.appendChild(option);
  });

  if (selectedTeacherCode) {
    assignTeacherCodeField.value = selectedTeacherCode;
  }
}

function populateSubjectOptions() {
  const selectedClassCode = assignClassCodeField.value;
  const selectedSubjectCode = assignSubjectCodeField.value;
  const subjects = readRegisteredSubjects();

  assignSubjectCodeField.innerHTML = "";
  const placeholder = document.createElement("option");
  placeholder.value = "";
  placeholder.textContent = selectedClassCode ? "Select subject" : "Select a class code first";
  placeholder.disabled = true;
  placeholder.selected = true;
  assignSubjectCodeField.appendChild(placeholder);

  if (!selectedClassCode) {
    assignDepartmentField.value = "";
    return;
  }

  subjects
    .filter((item) => String(item.classCode || item.class_code || "").toUpperCase() === selectedClassCode.toUpperCase())
    .sort((a, b) => String(a.subjectName || "").localeCompare(String(b.subjectName || "")))
    .forEach((subject) => {
      const option = document.createElement("option");
      const subjectCode = String(subject.subjectCode || "");
      if (!subjectCode) {
        return;
      }

      option.value = subjectCode;
      option.textContent = `${subject.subjectName} (${subjectCode})`;
      option.dataset.departmentName = String(subject.departmentName || "");
      option.dataset.departmentCode = String(subject.departmentCode || "");
      option.dataset.departmentId = String(subject.departmentId || subject.department_id || "");
      assignSubjectCodeField.appendChild(option);
    });

  if (selectedSubjectCode) {
    assignSubjectCodeField.value = selectedSubjectCode;
  }

  syncAssignmentDepartmentFromSubject();
}

function syncAssignmentDepartmentFromSubject() {
  const selectedOption = assignSubjectCodeField.selectedOptions[0];
  if (!selectedOption || !selectedOption.value) {
    assignDepartmentField.value = "";
    return;
  }

  const departmentName = selectedOption.dataset.departmentName || "";
  const departmentCode = selectedOption.dataset.departmentCode || "";
  assignDepartmentField.value = departmentName && departmentCode
    ? `${departmentName} (${departmentCode})`
    : departmentName;
}

function renderAssignmentsTable() {
  const assignments = readClassAssignments();
  assignmentTableBody.innerHTML = "";

  if (assignments.length === 0) {
    assignmentEmptyState.classList.remove("d-none");
    return;
  }

  assignmentEmptyState.classList.add("d-none");

  assignments
    .slice()
    .sort((a, b) => String(a.classCode || "").localeCompare(String(b.classCode || "")))
    .forEach((assignment) => {
      const row = document.createElement("tr");
      row.innerHTML = `
        <td><strong>${assignment.classCode}</strong></td>
        <td>${assignment.subjectName} (${assignment.subjectCode})</td>
        <td>${assignment.departmentName || "-"}</td>
        <td>${assignment.teacherName} (${assignment.teacherCode})</td>
        <td>
          <button class="btn btn-sm btn-outline-danger" data-action="delete-assignment" data-key="${assignment.classCode}::${assignment.subjectCode}">Delete</button>
        </td>
      `;
      assignmentTableBody.appendChild(row);
    });
}

function saveAssignment() {
  const classCode = String(assignClassCodeField.value || "").trim().toUpperCase();
  const subjectCode = String(assignSubjectCodeField.value || "").trim().toUpperCase();
  const teacherCode = String(assignTeacherCodeField.value || "").trim().toUpperCase();

  if (!classCode || !subjectCode || !teacherCode) {
    showAssignmentMessage("danger", "Please select a class code, subject, and teacher.");
    return false;
  }

  const selectedSubjectOption = assignSubjectCodeField.selectedOptions[0];
  const selectedTeacherOption = assignTeacherCodeField.selectedOptions[0];

  const subjectName = selectedSubjectOption ? selectedSubjectOption.textContent.split(" (")[0] : "";
  const departmentName = selectedSubjectOption ? (selectedSubjectOption.dataset.departmentName || "") : "";
  const departmentCode = selectedSubjectOption ? (selectedSubjectOption.dataset.departmentCode || "") : "";
  const departmentId = selectedSubjectOption ? Number(selectedSubjectOption.dataset.departmentId || 0) || null : null;
  const teacherName = selectedTeacherOption ? selectedTeacherOption.textContent.split(" (")[0] : "";

  const assignments = readClassAssignments();
  const duplicate = assignments.some(
    (item) =>
      String(item.classCode || "").toUpperCase() === classCode &&
      String(item.subjectCode || "").toUpperCase() === subjectCode
  );

  if (duplicate) {
    showAssignmentMessage("danger", "This subject is already assigned to this class.");
    return false;
  }

  assignments.push({
    classCode,
    subjectCode,
    subjectName,
    departmentId,
    departmentCode,
    departmentName,
    teacherCode,
    teacherName,
    createdAt: new Date().toISOString()
  });

  writeClassAssignments(assignments);
  return true;
}

function deleteAssignment(key) {
  const assignments = readClassAssignments();
  const filtered = assignments.filter((item) => `${item.classCode}::${item.subjectCode}` !== key);

  if (filtered.length === assignments.length) {
    showAssignmentMessage("danger", "Assignment not found.");
    return;
  }

  writeClassAssignments(filtered);
  renderAssignmentsTable();
  showAssignmentMessage("success", "Assignment deleted successfully.");
}

assignmentTableBody.addEventListener("click", (event) => {
  const button = event.target.closest("button[data-action='delete-assignment']");
  if (!button) {
    return;
  }

  const key = String(button.dataset.key || "");
  if (!key) {
    return;
  }

  const shouldDelete = window.confirm("Delete this class assignment?");
  if (!shouldDelete) {
    return;
  }

  deleteAssignment(key);
});

assignmentForm.addEventListener("submit", (event) => {
  event.preventDefault();
  clearAssignmentMessage();

  if (!assignmentForm.checkValidity()) {
    showAssignmentMessage("danger", "Please complete all assignment fields.");
    return;
  }

  const saved = saveAssignment();
  if (!saved) {
    return;
  }

  assignmentForm.reset();
  assignDepartmentField.value = "";
  populateClassOptions();
  populateTeacherOptions();
  populateSubjectOptions();
  renderAssignmentsTable();
  showAssignmentMessage("success", "Assignment saved successfully.");
});

assignClassCodeField.addEventListener("change", () => {
  clearAssignmentMessage();
  populateSubjectOptions();
});

assignSubjectCodeField.addEventListener("change", () => {
  clearAssignmentMessage();
  syncAssignmentDepartmentFromSubject();
});

assignTeacherCodeField.addEventListener("change", () => {
  clearAssignmentMessage();
});

populateClassOptions();
populateTeacherOptions();
populateSubjectOptions();
renderAssignmentsTable();
