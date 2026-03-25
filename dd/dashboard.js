// Update Incident Form Handler
const updateForm = document.getElementById('updateIncidentForm');
const incidentMsg = document.getElementById('incidentMsg');

updateForm.addEventListener('submit', (e) => {
  e.preventDefault();
  incidentMsg.className = 'alert d-none mt-3 mb-0';

  const studentRef = document.getElementById('studentRef').value.trim();
  const incidentType = document.getElementById('incidentType').value;
  const description = document.getElementById('incidentDesc').value.trim();
  const actionTaken = document.getElementById('actionTaken').value;

  if (!studentRef || !incidentType || !description || !actionTaken) {
    incidentMsg.textContent = 'Please complete all fields.';
    incidentMsg.className = 'alert alert-danger mt-3 mb-0';
    return;
  }

  incidentMsg.textContent = '✓ Incident for ' + studentRef + ' (' + incidentType + ') recorded successfully.';
  incidentMsg.className = 'alert alert-success mt-3 mb-0';
  updateForm.reset();
});

// Search Incident History Handler
const searchForm = document.getElementById('searchIncidentForm');
const searchResults = document.getElementById('searchResults');
const resultCount = document.getElementById('resultCount');

searchForm.addEventListener('submit', (e) => {
  e.preventDefault();
  
  const student = document.getElementById('searchStudent').value.toLowerCase();
  const startDate = document.getElementById('startDate').value;
  const endDate = document.getElementById('endDate').value;
  const type = document.getElementById('filterType').value;
  const status = document.getElementById('filterStatus').value;

  let matchCount = 4;
  if (student || startDate || endDate || type || status) {
    matchCount = Math.max(0, 4 - Math.floor(Math.random() * 2));
  }

  resultCount.textContent = matchCount;
  searchResults.classList.remove('d-none');
});
