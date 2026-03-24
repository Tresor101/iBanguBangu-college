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

const children = [
  {
    id: "STU-20260304-1234",
    name: "John Doe",
    classLabel: "Grade 10 - A",
    schoolLevel: "high",
    attendancePercent: 94,
    attendancePresent: 47,
    attendanceTotal: 50,
    balance: 120,
    dueDate: "Mar 20",
    modules: [
      { subject: "Mathematics", baseScore: 89 },
      { subject: "Physics", baseScore: 84 },
      { subject: "Chemistry", baseScore: 82 },
      { subject: "Biology", baseScore: 86 },
      { subject: "English", baseScore: 80 },
      { subject: "History", baseScore: 91 },
      { subject: "Geography", baseScore: 83 },
      { subject: "Computer Studies", baseScore: 88 }
    ]
  },
  {
    id: "STU-20260304-4321",
    name: "Jane Doe",
    classLabel: "Grade 5 - B",
    schoolLevel: "primary",
    attendancePercent: 97,
    attendancePresent: 49,
    attendanceTotal: 50,
    balance: 0,
    dueDate: "No outstanding fee",
    modules: [
      { subject: "Mathematics", baseScore: 93 },
      { subject: "English", baseScore: 88 },
      { subject: "Science", baseScore: 90 },
      { subject: "Social Studies", baseScore: 86 },
      { subject: "French", baseScore: 84 },
      { subject: "Moral Education", baseScore: 91 }
    ]
  }
];

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

children.forEach((child, index) => {
  const option = document.createElement("option");
  option.value = child.id;
  option.textContent = `${child.name} (${child.classLabel})`;
  if (index === 0) {
    option.selected = true;
  }
  studentSelector.appendChild(option);
});

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

renderChild(children[0]);
