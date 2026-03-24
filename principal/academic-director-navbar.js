function renderAcademicDirectorNavbar(mountId = "appNavbar") {
  const mount = document.getElementById(mountId);
  if (!mount) {
    return;
  }

  mount.innerHTML = `
    <nav class="navbar navbar-expand-lg main-nav px-3 px-lg-4">
      <a class="navbar-brand" href="academic-director-dashboard.html">Kivu Sunrise</a>
      <div class="nav-actions">
        <a class="btn btn-light btn-sm fw-semibold" href="academic-director-dashboard.html">Home</a>
        <a class="btn btn-primary btn-sm fw-semibold" href="academic-director-dashboard.html">Dashboard</a>
        <a class="btn btn-warning btn-sm fw-semibold" href="deputy-academic-director-registration.html">Register Deputy Director</a>
        <a class="btn btn-outline-light btn-sm fw-semibold" href="../index.html">Logout</a>
      </div>
    </nav>
    <div class="main-nav-spacer" aria-hidden="true"></div>
  `;
}
