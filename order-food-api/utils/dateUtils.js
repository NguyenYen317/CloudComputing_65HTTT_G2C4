function nowIso() {
  return new Date().toISOString();
}

function toVietnamTimeString(value) {
  const date = value ? new Date(value) : new Date();
  return date.toLocaleString("vi-VN", { timeZone: "Asia/Ho_Chi_Minh" });
}

module.exports = {
  nowIso,
  toVietnamTimeString,
};
