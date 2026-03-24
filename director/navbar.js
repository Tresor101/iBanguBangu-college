(function () {
  function ensureNavbarStyles() {
    if (document.getElementById("dashboard-navbar-styles")) {
      return;
    }

    const style = document.createElement("style");
    style.id = "dashboard-navbar-styles";
    style.textContent = `
      .main-nav {
        border-radius: 0;
        background: rgba(15, 23, 42, 0.95);
        box-shadow: 0 10px 24px rgba(15, 23, 42, 0.2);
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        z-index: 1030;
        margin: 0;
      }

      .main-nav .navbar-brand {
        color: rgba(255, 255, 255, 0.9);
        font-weight: 600;
      }

      .main-nav .navbar-brand {
        margin-right: 1.2rem;
      }

      .main-nav .navbar-toggler {
        border-color: rgba(255, 255, 255, 0.35);
      }

      .main-nav .navbar-toggler-icon {
        filter: invert(1);
      }

      .main-nav-actions {
        display: flex;
        flex-wrap: wrap;
        gap: 0.5rem;
        margin-left: auto;
        justify-content: flex-end;
        width: 100%;
      }

      .main-nav-spacer {
        height: 78px;
      }
    `;

    document.head.appendChild(style);
  }

  window.renderDashboardNavbar = function renderDashboardNavbar(config) {
    const mountId = config && config.mountId ? config.mountId : "appNavbar";
    const mount = document.getElementById(mountId);

    if (!mount) {
      return;
    }

    ensureNavbarStyles();

    mount.innerHTML = `
      <nav class="navbar navbar-expand-lg main-nav px-3 px-lg-4">
        <a class="navbar-brand" href="#">Kivu Sunrise</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#dashboardNavbar" aria-controls="dashboardNavbar" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="dashboardNavbar">
          <div class="main-nav-actions">
            <a class="btn btn-light btn-sm fw-semibold" href="proprietor-dashboard.html">Dashboard</a>
            <a class="btn btn-warning btn-sm fw-semibold" href="leadership-registration-form.html">Leadership Registration</a>
            <a class="btn btn-outline-light btn-sm fw-semibold" href="../index.html">Logout</a>
          </div>
        </div>
      </nav>
      <div class="main-nav-spacer" aria-hidden="true"></div>
    `;
  };
})();
