function generateId(prefix = "ID") {
  return `${prefix}${Date.now()}`;
}

module.exports = generateId;
