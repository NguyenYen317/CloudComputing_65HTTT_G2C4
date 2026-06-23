let storage = null;

function getStorage() {
  if (storage) return storage;
  const { Storage } = require("@google-cloud/storage");
  storage = new Storage();
  return storage;
}

module.exports = {
  getStorage,
};
