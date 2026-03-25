const form = document.getElementById("signinForm");
const accountType = document.getElementById("accountType");
const accountId = document.getElementById("accountId");
const formAlert = document.getElementById("formAlert");

const destinationByType = {
  student: "../student/dashboard.html",
  parent: "../parent/dashboard.html"
};

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

  if (!accountType.value) {
    showAlert("Please select Student or Parent.", "error");
    return;
  }

  const trimmedId = accountId.value.trim();
  if (trimmedId.length < 3) {
    showAlert("Please enter a valid ID.", "error");
    return;
  }

  localStorage.setItem(
    "schoolPortalSession",
    JSON.stringify({
      type: accountType.value,
      id: trimmedId,
      signedInAt: new Date().toISOString()
    })
  );

  if (accountType.value === "parent") {
    localStorage.setItem("activeParentId", trimmedId);
  }

  if (accountType.value === "student") {
    localStorage.setItem("activeStudentId", trimmedId);
  }

  showAlert("Sign in successful. Redirecting...", "success");

  setTimeout(() => {
    window.location.href = destinationByType[accountType.value];
  }, 550);
});
