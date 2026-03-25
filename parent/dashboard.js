const studentSelector = document.getElementById("studentSelector");
const resultSelector = document.getElementById("resultSelector");
const statAttendancePercent = document.getElementById("statAttendancePercent");
const statAttendanceDetail = document.getElementById("statAttendanceDetail");
const statAverage = document.getElementById("statAverage");
const statPeriodLabel = document.getElementById("statPeriodLabel");
const statBalance = document.getElementById("statBalance");
const statDueDate = document.getElementById("statDueDate");
const profileName = document.getElementById("profileName");
const profileStudentId = document.getElementById("profileStudentId");
const profileClass = document.getElementById("profileClass");
const profileLevel = document.getElementById("profileLevel");
const resultsPeriodTag = document.getElementById("resultsPeriodTag");
const resultsBody = document.getElementById("resultsBody");
const parentIdInput = document.getElementById("parentIdInput");
const loadParentStudentsButton = document.getElementById("loadParentStudents");
const linkedStudentsMessage = document.getElementById("linkedStudentsMessage");
const parentDashboardSubtitle = document.getElementById("parentDashboardSubtitle");

let children = [];

function normalizeIdentifier(value) {
  return value.trim().toUpperCase();
}

function getStoredRegistrations() {
  try {
    const raw = localStorage.getItem("student-registrations");
    const parsed = raw ? JSON.parse(raw) : [];
    return Array.isArray(parsed) ? parsed : [];
  } catch (error) {
    return [];
  }
}

function getLevelFromGrade(grade) {
  const extracted = Number((grade || "").replace(/[^0-9]/g, ""));
  if (Number.isFinite(extracted) && extracted > 0 && extracted <= 6) {
    return "primary";
  }
  return "high";
}

function getModulesForLevel(level) {
  if (level === "primary") {
    return [
      { subject: "Mathematics", baseScore: 82 },
      { subject: "English", baseScore: 80 },
      { subject: "Science", baseScore: 79 },
      { subject: "Social Studies", baseScore: 78 },
      { subject: "French", baseScore: 77 },
      { subject: "Moral Education", baseScore: 81 }
    ];
  }

  return [
    { subject: "Mathematics", baseScore: 80 },
    { subject: "Physics", baseScore: 78 },
    { subject: "Chemistry", baseScore: 77 },
    { subject: "Biology", baseScore: 79 },
    { subject: "English", baseScore: 76 },
    { subject: "History", baseScore: 81 },
    { subject: "Geography", baseScore: 78 },
    { subject: "Computer Studies", baseScore: 82 }
  ];
}

function toChildProfile(registration, index) {
  const schoolLevel = getLevelFromGrade(registration.grade);
  const attendanceTotal = 50;
  const attendancePercent = Math.min(99, 92 + (index % 6));
  const attendancePresent = Math.round((attendancePercent / 100) * attendanceTotal);

  return {
    id: registration.studentId,
    name: `${registration.firstName} ${registration.lastName}`.trim(),
    classLabel: registration.grade || "Unassigned",
    schoolLevel,
    attendancePercent,
    attendancePresent,
    attendanceTotal,
    balance: 0,
    dueDate: "No outstanding fee",
    modules: getModulesForLevel(schoolLevel)
  };
}

function setLinkedStudentsMessage(text, style) {
  linkedStudentsMessage.className = `alert alert-${style} py-2 mb-3`;
  linkedStudentsMessage.textContent = text;
}

function getLevelLabel(level) {
  return level === "primary" ? "Primary School" : "High School";
}

function getTotalTerms(level) {
  return level === "primary" ? 9 : 4;
}

function buildResultOptions(level) {
  const options = [];

  for (let term = 1; term <= getTotalTerms(level); term += 1) {
    options.push({ type: "term", term, label: `Term ${term} Assessment` });
    if (term % 2 === 0) {
      options.push({
        type: "semester",
        term,
        semester: term / 2,
        label: `Semester ${term / 2} Test`
      });
    }
  }

  return options;
}

function getRemarkBadge(score) {
  if (score >= 90) {
    return { grade: "A", remark: "Excellent", badge: "success" };
  }
  if (score >= 85) {
    return { grade: "A-", remark: "Very Good", badge: "primary" };
  }
  if (score >= 75) {
    return { grade: "B", remark: "Good", badge: "info" };
  }
  if (score >= 65) {
    return { grade: "C", remark: "Fair", badge: "warning" };
  }
  return { grade: "D", remark: "Needs Support", badge: "danger" };
}

function getScoreAdjustment(resultOption) {
  const baseTermShift = Math.max(0, resultOption.term - 1);
  if (resultOption.type === "semester") {
    return baseTermShift + 2;
  }
  return baseTermShift;
}

function getRenderedResults(child, resultOption) {
  const adjustment = getScoreAdjustment(resultOption);

  return child.modules.map((item) => {
    const score = Math.min(100, item.baseScore + adjustment);
    const rating = getRemarkBadge(score);
    return {
      subject: item.subject,
      score,
      grade: rating.grade,
      remark: rating.remark,
      badge: rating.badge
    };
  });
}

function renderResults(results) {
  resultsBody.innerHTML = results
    .map(
      (item) => `
        <tr>
          <td>${item.subject}</td>
          <td>${item.score}</td>
          <td>${item.grade}</td>
          <td><span class="badge text-bg-${item.badge}">${item.remark}</span></td>
        </tr>
      `
    )
    .join("");
}

function renderAverage(results) {
  const total = results.reduce((sum, item) => sum + item.score, 0);
  const average = Math.round(total / Math.max(1, results.length));
  statAverage.textContent = `${average}%`;
}

function renderResultOptionsForChild(child) {
  const options = buildResultOptions(child.schoolLevel);
  resultSelector.innerHTML = "";

  options.forEach((item, index) => {
    const option = document.createElement("option");
    option.value = `${item.type}|${item.term}|${item.semester || ""}`;
    option.textContent = item.label;
    if (index === 0) {
      option.selected = true;
    }
    resultSelector.appendChild(option);
  });
}

function getSelectedResult() {
  const [typePart, termPart, semesterPart] = (resultSelector.value || "term|1|").split("|");
  const term = Number(termPart || "1");
  const semester = semesterPart ? Number(semesterPart) : null;
  const label = typePart === "semester" ? `Semester ${semester} Test` : `Term ${term} Assessment`;
  return {
    type: typePart === "semester" ? "semester" : "term",
    term,
    semester,
    label
  };
}

function renderAssessmentForChild(child) {
  const selectedResult = getSelectedResult();
  const renderedResults = getRenderedResults(child, selectedResult);

  statPeriodLabel.textContent = selectedResult.label;
  resultsPeriodTag.textContent = selectedResult.label;
  renderAverage(renderedResults);
  renderResults(renderedResults);
}

function renderChild(child) {
  statAttendancePercent.textContent = `${child.attendancePercent}%`;
  statAttendanceDetail.textContent = `Present: ${child.attendancePresent} / ${child.attendanceTotal} days`;
  statBalance.textContent = `$${child.balance}`;
  statDueDate.textContent = child.balance > 0 ? `Due date: ${child.dueDate}` : child.dueDate;

  profileName.textContent = child.name;
  profileStudentId.textContent = child.id;
  profileClass.textContent = child.classLabel;
  profileLevel.textContent = getLevelLabel(child.schoolLevel);

  renderResultOptionsForChild(child);
  renderAssessmentForChild(child);
}

function renderEmptyDashboard() {
  studentSelector.innerHTML = "";
  resultSelector.innerHTML = "";
  statAttendancePercent.textContent = "0%";
  statAttendanceDetail.textContent = "Present: 0 / 0 days";
  statAverage.textContent = "0%";
  statPeriodLabel.textContent = "No data";
  statBalance.textContent = "$0";
  statDueDate.textContent = "No outstanding fee";
  profileName.textContent = "-";
  profileStudentId.textContent = "-";
  profileClass.textContent = "-";
  profileLevel.textContent = "-";
  resultsPeriodTag.textContent = "No result records";
  resultsBody.innerHTML = '<tr><td colspan="4" class="text-secondary">No students linked to this parent ID yet.</td></tr>';
}

function populateChildSelector() {
  studentSelector.innerHTML = "";
  children.forEach((child, index) => {
    const option = document.createElement("option");
    option.value = child.id;
    option.textContent = `${child.name} (${child.classLabel})`;
    if (index === 0) {
      option.selected = true;
    }
    studentSelector.appendChild(option);
  });
}

function loadChildrenForParent(parentIdValue) {
  const parentId = normalizeIdentifier(parentIdValue);
  parentIdInput.value = parentId;

  if (!parentId) {
    children = [];
    renderEmptyDashboard();
    parentDashboardSubtitle.textContent = "Enter Parent ID to load linked students.";
    setLinkedStudentsMessage("Please enter Parent ID.", "warning");
    return;
  }

  const registrations = getStoredRegistrations();
  const linkedRegistrations = registrations.filter(
    (item) => normalizeIdentifier(item.parentId || "") === parentId
  );

  if (linkedRegistrations.length === 0) {
    children = [];
    renderEmptyDashboard();
    parentDashboardSubtitle.textContent = `No linked students found for ${parentId}.`;
    setLinkedStudentsMessage("No students found for this Parent ID.", "warning");
    return;
  }

  localStorage.setItem("current-parent-id", parentId);
  children = linkedRegistrations.map((item, index) => toChildProfile(item, index));
  populateChildSelector();
  renderChild(children[0]);

  parentDashboardSubtitle.textContent = `Showing students linked to ${parentId}.`;
  setLinkedStudentsMessage(`Loaded ${children.length} student(s) for Parent ID ${parentId}.`, "success");
}

studentSelector.addEventListener("change", () => {
  const selected = children.find((child) => child.id === studentSelector.value);
  if (selected) {
    renderChild(selected);
  }
});

resultSelector.addEventListener("change", () => {
  const selected = children.find((child) => child.id === studentSelector.value);
  if (selected) {
    renderAssessmentForChild(selected);
  }
});

loadParentStudentsButton.addEventListener("click", () => {
  loadChildrenForParent(parentIdInput.value);
});

parentIdInput.addEventListener("keydown", (event) => {
  if (event.key === "Enter") {
    event.preventDefault();
    loadChildrenForParent(parentIdInput.value);
  }
});

const queryParentId = new URLSearchParams(window.location.search).get("parentId");
const cachedParentId = localStorage.getItem("current-parent-id") || "";
const initialParentId = queryParentId || cachedParentId;

if (initialParentId) {
  loadChildrenForParent(initialParentId);
} else {
  renderEmptyDashboard();
}
