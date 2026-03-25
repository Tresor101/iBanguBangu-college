const classSelector = document.getElementById("classSelector");
const statClasses = document.getElementById("statClasses");
const statStudents = document.getElementById("statStudents");
const statAttendance = document.getElementById("statAttendance");
const statSubjectLabel = document.getElementById("statSubjectLabel");
const statPending = document.getElementById("statPending");
const overviewName = document.getElementById("overviewName");
const overviewSubject = document.getElementById("overviewSubject");
const overviewNext = document.getElementById("overviewNext");
const performanceBody = document.getElementById("performanceBody");
const gradeBody = document.getElementById("gradeBody");
const saveGradesBtn = document.getElementById("saveGradesBtn");
const gradeMessage = document.getElementById("gradeMessage");

const classes = [
  {
    id: "G10A-MATH",
    name: "Grade 10 - A",
    subject: "Mathematics",
    totalClasses: 4,
    students: 38,
    attendanceToday: 96,
    pendingGrading: 12,
    nextSession: "Tomorrow, 08:00 AM",
    performance: [
      { student: "John Doe", average: 92, attendance: 98, status: "Excellent", badge: "success" },
      { student: "Mary Lee", average: 89, attendance: 96, status: "Strong", badge: "primary" },
      { student: "Ali Hassan", average: 87, attendance: 94, status: "Good", badge: "info" },
      { student: "Daniel Kim", average: 84, attendance: 93, status: "Improving", badge: "warning" }
    ]
  },
  {
    id: "G9B-SCI",
    name: "Grade 9 - B",
    subject: "Science",
    totalClasses: 5,
    students: 34,
    attendanceToday: 93,
    pendingGrading: 7,
    nextSession: "Today, 01:00 PM",
    performance: [
      { student: "Ava Patel", average: 90, attendance: 97, status: "Excellent", badge: "success" },
      { student: "Lucas Brown", average: 88, attendance: 95, status: "Strong", badge: "primary" },
      { student: "Nora Ahmed", average: 85, attendance: 92, status: "Good", badge: "info" },
      { student: "Ivy Chen", average: 82, attendance: 90, status: "Improving", badge: "warning" }
    ]
  }
];

function getStatusFromScore(score) {
  if (score >= 90) {
    return { status: "Excellent", badge: "success" };
  }
  if (score >= 85) {
    return { status: "Strong", badge: "primary" };
  }
  if (score >= 75) {
    return { status: "Good", badge: "info" };
  }
  return { status: "Improving", badge: "warning" };
}

function renderPerformance(performance) {
  performanceBody.innerHTML = performance
    .map(
      (item) => `
        <tr>
          <td>${item.student}</td>
          <td>${item.average}%</td>
        </tr>
      `
    )
    .join("");
}

function renderGradeEditor(selectedClass) {
  gradeBody.innerHTML = selectedClass.performance
    .map(
      (item, index) => `
        <tr>
          <td>${item.student}</td>
          <td>
            <input
              type="number"
              class="form-control"
              min="0"
              max="100"
              step="1"
              value="${item.average}"
              data-student="${item.student}"
              id="gradeInput-${index}"
            />
          </td>
        </tr>
      `
    )
    .join("");
}

function computeClassAverage(performance) {
  if (!performance || performance.length === 0) {
    return 0;
  }
  const total = performance.reduce((sum, item) => sum + item.average, 0);
  return Math.round(total / performance.length);
}

function renderClass(selectedClass) {
  statClasses.textContent = selectedClass.totalClasses;
  const classAvg = computeClassAverage(selectedClass.performance);
  statStudents.textContent = `${classAvg}%`;
  statSubjectLabel.textContent = `${selectedClass.subject} · ${selectedClass.name}`;
  statAttendance.textContent = `Attendance today: ${selectedClass.attendanceToday}%`;
  statPending.textContent = selectedClass.pendingGrading;

  overviewName.textContent = selectedClass.name;
  overviewSubject.textContent = selectedClass.subject;
  overviewNext.textContent = selectedClass.nextSession;

  renderPerformance(selectedClass.performance);
  renderGradeEditor(selectedClass);
  gradeMessage.className = "alert d-none mt-3 mb-0";
  gradeMessage.textContent = "";
}

classes.forEach((classItem, index) => {
  const option = document.createElement("option");
  option.value = classItem.id;
  option.textContent = `${classItem.name} (${classItem.subject})`;
  if (index === 0) {
    option.selected = true;
  }
  classSelector.appendChild(option);
});

classSelector.addEventListener("change", () => {
  const selectedClass = classes.find((item) => item.id === classSelector.value);
  if (selectedClass) {
    renderClass(selectedClass);
  }
});

saveGradesBtn.addEventListener("click", () => {
  const selectedClass = classes.find((item) => item.id === classSelector.value);
  if (!selectedClass) {
    return;
  }

  const inputs = Array.from(gradeBody.querySelectorAll("input[type='number']"));
  const updates = [];

  for (const input of inputs) {
    const mark = Number(input.value);
    if (!Number.isFinite(mark) || mark < 0 || mark > 100) {
      gradeMessage.textContent = "Please enter valid marks between 0 and 100 for all students.";
      gradeMessage.className = "alert alert-danger mt-3 mb-0";
      input.focus();
      return;
    }
    updates.push({ student: input.dataset.student, average: Math.round(mark) });
  }

  selectedClass.performance = selectedClass.performance.map((item) => {
    const updated = updates.find((u) => u.student === item.student);
    if (!updated) {
      return item;
    }
    const statusMeta = getStatusFromScore(updated.average);
    return {
      ...item,
      average: updated.average,
      status: statusMeta.status,
      badge: statusMeta.badge
    };
  });

  renderPerformance(selectedClass.performance);
  gradeMessage.textContent = "Marks saved successfully.";
  gradeMessage.className = "alert alert-success mt-3 mb-0";
});

renderClass(classes[0]);
