renderDashboardNavbar({ mountId: "appNavbar", active: "proprietor" });

const termSelector = document.getElementById("termSelector");
const statEnrollment = document.getElementById("statEnrollment");
const statNewAdmissions = document.getElementById("statNewAdmissions");
const statRevenue = document.getElementById("statRevenue");
const statCollectionRate = document.getElementById("statCollectionRate");
const statStaff = document.getElementById("statStaff");
const statTeachers = document.getElementById("statTeachers");
const statCompliance = document.getElementById("statCompliance");
const statAudit = document.getElementById("statAudit");
const overviewYear = document.getElementById("overviewYear");
const overviewCampuses = document.getElementById("overviewCampuses");
const overviewDirector = document.getElementById("overviewDirector");
const overviewReview = document.getElementById("overviewReview");
const passRate = document.getElementById("passRate");
const outstandingFees = document.getElementById("outstandingFees");
const retentionRate = document.getElementById("retentionRate");
const departmentBody = document.getElementById("departmentBody");
const feesBody = document.getElementById("feesBody");
const tasksList = document.getElementById("tasksList");
const announcementsList = document.getElementById("announcementsList");

const reports = [
  {
    id: "2025-T1",
    label: "2025-2026 • Term 1",
    academicYear: "2025-2026",
    campuses: 2,
    director: "Mr. Joel Mbuyi",
    boardReview: "Mar 28, 2026",
    enrollment: 824,
    newAdmissions: 96,
    revenue: "$124k",
    collectionRate: 88,
    staff: 61,
    teachers: 44,
    compliance: 92,
    auditActions: 3,
    passRate: 84,
    outstandingFees: "$17k",
    retentionRate: 95,
    departments: [
      { name: "Academics", head: "Mrs. Chantal Ilunga", performance: "86%", status: "Strong", badge: "success" },
      { name: "Finance", head: "Mr. Patrick Kasongo", performance: "88%", status: "Stable", badge: "primary" },
      { name: "Discipline", head: "Mr. Daniel Banza", performance: "81%", status: "Needs Follow-up", badge: "warning" },
      { name: "Administration", head: "Ms. Ruth Mukendi", performance: "90%", status: "On Track", badge: "success" }
    ],
    fees: [
      { group: "Nursery & Primary", expected: "$38,000", collected: "$33,600", balance: "$4,400" },
      { group: "Lower Secondary", expected: "$46,000", collected: "$40,900", balance: "$5,100" },
      { group: "Upper Secondary", expected: "$57,000", collected: "$50,100", balance: "$6,900" }
    ],
    tasks: [
      { title: "Approve revised transport budget", due: "Today", priority: "High" },
      { title: "Review bursar fee recovery plan", due: "Tomorrow", priority: "High" },
      { title: "Validate next term staffing proposal", due: "This week", priority: "Medium" },
      { title: "Sign ministry compliance letter", due: "This week", priority: "Medium" }
    ],
    announcements: [
      { title: "School inspection scheduled", detail: "Provincial inspection team expected on Mar 21." },
      { title: "Science lab renovation approved", detail: "Works start during the holiday break." },
      { title: "Fee payment extension", detail: "Extension granted to families affected by delayed salaries." }
    ]
  },
  {
    id: "2025-T2",
    label: "2025-2026 • Term 2",
    academicYear: "2025-2026",
    campuses: 2,
    director: "Mr. Joel Mbuyi",
    boardReview: "Jun 18, 2026",
    enrollment: 841,
    newAdmissions: 28,
    revenue: "$131k",
    collectionRate: 91,
    staff: 63,
    teachers: 46,
    compliance: 95,
    auditActions: 1,
    passRate: 87,
    outstandingFees: "$12k",
    retentionRate: 96,
    departments: [
      { name: "Academics", head: "Mrs. Chantal Ilunga", performance: "89%", status: "Strong", badge: "success" },
      { name: "Finance", head: "Mr. Patrick Kasongo", performance: "92%", status: "Excellent", badge: "success" },
      { name: "Discipline", head: "Mr. Daniel Banza", performance: "84%", status: "Improving", badge: "info" },
      { name: "Administration", head: "Ms. Ruth Mukendi", performance: "93%", status: "On Track", badge: "success" }
    ],
    fees: [
      { group: "Nursery & Primary", expected: "$39,500", collected: "$36,700", balance: "$2,800" },
      { group: "Lower Secondary", expected: "$48,400", collected: "$44,900", balance: "$3,500" },
      { group: "Upper Secondary", expected: "$58,900", collected: "$53,200", balance: "$5,700" }
    ],
    tasks: [
      { title: "Approve classroom furniture purchase", due: "Today", priority: "High" },
      { title: "Review teacher recruitment shortlist", due: "Tomorrow", priority: "High" },
      { title: "Confirm exam security budget", due: "This week", priority: "Medium" },
      { title: "Inspect girls dormitory maintenance report", due: "This week", priority: "Low" }
    ],
    announcements: [
      { title: "Term 2 exam preparation underway", detail: "Printing and supervision plans have started." },
      { title: "Fee recovery improved", detail: "Outstanding balance reduced by 29% compared to Term 1." },
      { title: "Teacher housing support proposal", detail: "Draft package submitted for promoter review." }
    ]
  }
];

function renderDepartments(items) {
  departmentBody.innerHTML = items
    .map(
      (item) => `
        <tr>
          <td>${item.name}</td>
          <td>${item.head}</td>
          <td>${item.performance}</td>
          <td><span class="badge text-bg-${item.badge}">${item.status}</span></td>
        </tr>
      `
    )
    .join("");
}

function renderFees(items) {
  feesBody.innerHTML = items
    .map(
      (item) => `
        <tr>
          <td>${item.group}</td>
          <td>${item.expected}</td>
          <td>${item.collected}</td>
          <td>${item.balance}</td>
        </tr>
      `
    )
    .join("");
}

function priorityBadge(priority) {
  if (priority === "High") {
    return "danger";
  }
  if (priority === "Medium") {
    return "warning";
  }
  return "secondary";
}

function renderTasks(items) {
  tasksList.innerHTML = items
    .map(
      (item) => `
        <li class="list-group-item px-0 d-flex justify-content-between align-items-center gap-3">
          <div>
            <div class="fw-semibold">${item.title}</div>
            <div class="small text-secondary">Due: ${item.due}</div>
          </div>
          <span class="badge text-bg-${priorityBadge(item.priority)}">${item.priority}</span>
        </li>
      `
    )
    .join("");
}

function renderAnnouncements(items) {
  announcementsList.innerHTML = items
    .map(
      (item) => `
        <li class="list-group-item px-0">
          <div class="fw-semibold">${item.title}</div>
          <div class="small text-secondary">${item.detail}</div>
        </li>
      `
    )
    .join("");
}

function renderReport(report) {
  statEnrollment.textContent = report.enrollment;
  statNewAdmissions.textContent = `New admissions: ${report.newAdmissions}`;
  statRevenue.textContent = report.revenue;
  statCollectionRate.textContent = `Collection rate: ${report.collectionRate}%`;
  statStaff.textContent = report.staff;
  statTeachers.textContent = `Teachers: ${report.teachers}`;
  statCompliance.textContent = `${report.compliance}%`;
  statAudit.textContent = `Audit actions open: ${report.auditActions}`;
  overviewYear.textContent = report.academicYear;
  overviewCampuses.textContent = report.campuses;
  overviewDirector.textContent = report.director;
  overviewReview.textContent = report.boardReview;
  passRate.textContent = `${report.passRate}%`;
  outstandingFees.textContent = report.outstandingFees;
  retentionRate.textContent = `${report.retentionRate}%`;

  renderDepartments(report.departments);
  renderFees(report.fees);
  renderTasks(report.tasks);
  renderAnnouncements(report.announcements);
}

reports.forEach((report, index) => {
  const option = document.createElement("option");
  option.value = report.id;
  option.textContent = report.label;
  if (index === 0) {
    option.selected = true;
  }
  termSelector.appendChild(option);
});

termSelector.addEventListener("change", () => {
  const selectedReport = reports.find((item) => item.id === termSelector.value);
  if (selectedReport) {
    renderReport(selectedReport);
  }
});

renderReport(reports[0]);
