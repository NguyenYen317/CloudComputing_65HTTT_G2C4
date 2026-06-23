function isEmail(value) {
  return /^[^@]+@[^@]+\.[^@]+$/.test(String(value || ""));
}

function required(value) {
  return value !== undefined && value !== null && String(value).trim() !== "";
}

module.exports = {
  isEmail,
  required,
};
