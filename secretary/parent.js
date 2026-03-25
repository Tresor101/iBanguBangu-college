const form = document.getElementById("parentForm");
const formMessage = document.getElementById("formMessage");
const parentCodeField = document.getElementById("parentCode");
const secondFullName = document.getElementById("secondFullName");
const secondRelationship = document.getElementById("secondRelationship");
const secondPhone = document.getElementById("secondPhone");

function generateParentCode() {
  const now = new Date();
  const yearShort = String(now.getFullYear()).slice(-2);
  const storageKey = `parent-code-counter-${yearShort}`;

  let nextCounter = 1;
  try {
    const storedCounter = Number(localStorage.getItem(storageKey) || "0");
    nextCounter = Number.isFinite(storedCounter) ? storedCounter + 1 : 1;
    localStorage.setItem(storageKey, String(nextCounter));
  } catch (error) {
    nextCounter = Math.floor(1 + Math.random() * 9999);
  }

  return `PAR${yearShort}${String(nextCounter).padStart(4, "0")}`;
}

function syncParentCode() {
  parentCodeField.value = generateParentCode();
}

function normalize(value) {
  return value.trim().replace(/\s+/g, " ");
}

syncParentCode();

form.addEventListener("submit", (event) => {
  event.preventDefault();
  formMessage.classList.add("d-none");

  secondFullName.value = normalize(secondFullName.value);
  secondRelationship.value = normalize(secondRelationship.value);
  secondPhone.value = normalize(secondPhone.value);

  const hasSecondGuardianData = Boolean(
    secondFullName.value || secondRelationship.value || secondPhone.value
  );

  if (hasSecondGuardianData && (!secondFullName.value || !secondRelationship.value || !secondPhone.value)) {
    form.classList.add("was-validated");
    formMessage.textContent = "Complete all second guardian fields or leave them all empty.";
    formMessage.className = "alert alert-danger mt-3 mb-0";
    return;
  }

  if (!form.checkValidity()) {
    form.classList.add("was-validated");
    formMessage.textContent = "Please fix the highlighted fields and try again.";
    formMessage.className = "alert alert-danger mt-3 mb-0";
    return;
  }

  formMessage.textContent = hasSecondGuardianData
    ? "Parent profile with second guardian registered successfully."
    : "Parent registered successfully.";
  formMessage.className = "alert alert-success mt-3 mb-0";
  form.reset();
  syncParentCode();
  form.classList.remove("was-validated");
});
