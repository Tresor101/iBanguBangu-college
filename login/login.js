const roleRoutes = {
  superadmin: "../superadmin/dashboard.html",
  director: "../school-director-dashboard.html",
  principal: "../principal/dashboard.html",
  deputy: "../deputy_principal/dashboard.html",
  secretary: "../secretary/dashboard.html",
  bursary: "../bursary/dashboard.html",
  discipline: "../dd/dashboard.html",
  teacher: "../teacher/dashboard.html",
  parent: "../parent/dashboard.html",
  student: "../student/dashboard.html"
};

const form = document.getElementById("loginForm");
const role = document.getElementById("role");
const userId = document.getElementById("userId");
const password = document.getElementById("password");
const rememberMe = document.getElementById("rememberMe");
const formAlert = document.getElementById("formAlert");
const togglePass = document.getElementById("togglePass");

togglePass.addEventListener("click", () => {
  const isPassword = password.type === "password";
  password.type = isPassword ? "text" : "password";
  togglePass.textContent = isPassword ? "Hide" : "Show";
});

function showAlert(message, type) {
  formAlert.textContent = message;
  formAlert.className = "alert " + type;
}

function clearAlert() {
  formAlert.textContent = "";
  formAlert.className = "alert";
}

form.addEventListener("submit", (event) => {
  event.preventDefault();
  clearAlert();

  if (!role.value) {
    showAlert("Please select your account type.", "error");
    return;
  }

  if (!userId.value || userId.value.trim().length < 3) {
    showAlert("Enter a valid user ID or email.", "error");
    return;
  }

  if (!password.value || password.value.length < 6) {
    showAlert("Password must be at least 6 characters.", "error");
    return;
  }

  const destination = roleRoutes[role.value];
  if (!destination) {
    showAlert("This role is not configured yet.", "error");
    return;
  }

  // Store a light session payload for demo navigation across dashboards.
  const sessionPayload = {
    role: role.value,
    userId: userId.value.trim(),
    remember: rememberMe.checked,
    loggedInAt: new Date().toISOString()
  };
  localStorage.setItem("schoolPortalSession", JSON.stringify(sessionPayload));

  showAlert("Login successful. Redirecting to your dashboard...", "success");
  setTimeout(() => {
    window.location.href = destination;
  }, 650);
});
