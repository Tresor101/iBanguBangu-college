const paymentForm = document.getElementById("newPaymentForm");
const paymentMsg = document.getElementById("paymentUpdateMsg");
const collectedEl = document.getElementById("collectedThisTerm");
const outstandingEl = document.getElementById("outstandingBalance");
const paymentsTodayEl = document.getElementById("paymentsToday");

const studentRefInput = document.getElementById("studentRef");
const amountInput = document.getElementById("paymentAmount");
const currencyInput = document.getElementById("paymentCurrency");
const submitBtn = document.getElementById("submitPaymentBtn");
const submitBtnText = document.getElementById("submitBtnText");
const submitBtnSpinner = document.getElementById("submitBtnSpinner");

const paymentConfirmModal = new bootstrap.Modal(document.getElementById("paymentConfirmModal"));
const confirmPaymentBtn = document.getElementById("confirmPaymentBtn");
const confirmBtnText = document.getElementById("confirmBtnText");
const confirmBtnSpinner = document.getElementById("confirmBtnSpinner");

// Store form data for confirmation
let pendingPayment = null;

function formatCurrency(value, currencyCode) {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: currencyCode,
    maximumFractionDigits: 0
  }).format(value);
}

function validateStudentReference(ref) {
  // Accept formats: "STU-YYYYMMDD-XXXX", names with spaces, or alphanumeric
  return ref.length >= 3 && /^[a-zA-Z0-9\s\-]+$/.test(ref);
}

function updateStudentRefFeedback() {
  const ref = studentRefInput.value.trim();
  const feedback = document.getElementById("studentRefFeedback");
  const isValid = !ref || validateStudentReference(ref);
  
  if (ref.length === 0) {
    feedback.textContent = "";
    studentRefInput.classList.remove("is-invalid", "is-valid");
  } else if (isValid) {
    feedback.textContent = "✓ Valid student reference";
    feedback.style.color = "#28a745";
    studentRefInput.classList.remove("is-invalid");
    studentRefInput.classList.add("is-valid");
  } else {
    feedback.textContent = "✗ Invalid format (use name or STU-YYYYMMDD-XXXX)";
    feedback.style.color = "#dc3545";
    studentRefInput.classList.add("is-invalid");
  }
}

function updateAmountFeedback() {
  const amount = Number(amountInput.value);
  const feedback = document.getElementById("amountFeedback");
  
  if (amountInput.value === "") {
    feedback.textContent = "";
    amountInput.classList.remove("is-invalid", "is-valid");
  } else if (amount > 0 && Number.isFinite(amount)) {
    if (amount > 5000) {
      feedback.textContent = `⚠ Large amount (${formatCurrency(amount, currencyInput.value)})`;
      feedback.style.color = "#ff6c00";
    } else {
      feedback.textContent = formatCurrency(amount, currencyInput.value);
      feedback.style.color = "#28a745";
    }
    amountInput.classList.remove("is-invalid");
    amountInput.classList.add("is-valid");
  } else {
    feedback.textContent = "";
    amountInput.classList.add("is-invalid");
  }
}

// Real-time validation feedback
studentRefInput.addEventListener("input", updateStudentRefFeedback);
amountInput.addEventListener("input", updateAmountFeedback);
currencyInput.addEventListener("change", updateAmountFeedback);

// Form submit - show confirmation modal
paymentForm.addEventListener("submit", (event) => {
  event.preventDefault();
  paymentMsg.className = "alert d-none mt-3 mb-0";

  // Validate form
  if (!paymentForm.checkValidity() === false) {
    // Continue to our custom validation
  } else {
    paymentForm.classList.add("was-validated");
    paymentMsg.textContent = "Complete all payment fields before updating.";
    paymentMsg.className = "alert alert-danger mt-3 mb-0";
    return;
  }

  const studentRef = studentRefInput.value.trim();
  const amount = Number(amountInput.value);
  const paymentCurrency = currencyInput.value;

  // Validation checks
  if (!studentRef || !validateStudentReference(studentRef)) {
    paymentMsg.textContent = "Enter a valid student reference.";
    paymentMsg.className = "alert alert-danger mt-3 mb-0";
    studentRefInput.classList.add("is-invalid");
    return;
  }

  if (!Number.isFinite(amount) || amount <= 0) {
    paymentMsg.textContent = "Enter a valid amount greater than zero.";
    paymentMsg.className = "alert alert-danger mt-3 mb-0";
    amountInput.classList.add("is-invalid");
    return;
  }

  // Calculate preview
  const currentCollected = Number(collectedEl.dataset.value || "0");
  const currentOutstanding = Number(outstandingEl.dataset.value || "0");
  const newCollected = currentCollected + amount;
  const newOutstanding = Math.max(0, currentOutstanding - amount);

  // Store payment data and populate modal
  pendingPayment = {
    studentRef,
    amount,
    paymentCurrency,
    newCollected,
    newOutstanding
  };

  document.getElementById("confirmStudent").textContent = studentRef;
  document.getElementById("confirmAmount").textContent = formatCurrency(amount, paymentCurrency);
  document.getElementById("confirmCurrency").textContent = paymentCurrency;
  document.getElementById("previewCollected").textContent = formatCurrency(newCollected, paymentCurrency);
  document.getElementById("previewOutstanding").textContent = formatCurrency(newOutstanding, paymentCurrency);

  // Show modal
  paymentConfirmModal.show();
});

// Confirmation modal submit
confirmPaymentBtn.addEventListener("click", () => {
  if (!pendingPayment) return;

  // Show loading state
  confirmPaymentBtn.disabled = true;
  confirmBtnText.classList.add("d-none");
  confirmBtnSpinner.classList.remove("d-none");

  // Simulate processing delay
  setTimeout(() => {
    const { studentRef, amount, paymentCurrency, newCollected, newOutstanding } = pendingPayment;
    const paymentCount = Number(paymentsTodayEl.dataset.value || "0") + 1;

    // Update DOM
    collectedEl.dataset.value = String(newCollected);
    outstandingEl.dataset.value = String(newOutstanding);
    collectedEl.dataset.currency = paymentCurrency;
    outstandingEl.dataset.currency = paymentCurrency;
    paymentsTodayEl.dataset.value = String(paymentCount);

    collectedEl.textContent = formatCurrency(newCollected, paymentCurrency);
    outstandingEl.textContent = formatCurrency(newOutstanding, paymentCurrency);
    paymentsTodayEl.textContent = String(paymentCount);

    // Show success message
    paymentMsg.textContent = `✓ ${studentRef} payment of ${formatCurrency(amount, paymentCurrency)} recorded successfully.`;
    paymentMsg.className = "alert alert-success mt-3 mb-0";

    // Reset form
    paymentForm.reset();
    paymentForm.classList.remove("was-validated");
    studentRefInput.classList.remove("is-invalid", "is-valid");
    amountInput.classList.remove("is-invalid", "is-valid");
    document.getElementById("studentRefFeedback").textContent = "";
    document.getElementById("amountFeedback").textContent = "";

    // Reset button
    confirmPaymentBtn.disabled = false;
    confirmBtnText.classList.remove("d-none");
    confirmBtnSpinner.classList.add("d-none");

    // Close modal
    paymentConfirmModal.hide();
    pendingPayment = null;
  }, 800);
});
