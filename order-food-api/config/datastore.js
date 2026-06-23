let datastore = null;
const inMemoryStore = new Map();

function shouldUseLocalDatastore() {
  return process.env.ENABLE_LOCAL_DATASTORE === "true" || process.env.NODE_ENV !== "production";
}

function createLocalDatastore() {
  return {
    key([kind, name]) {
      return { kind, name };
    },
    async get(key) {
      const value = inMemoryStore.get(`${key.kind}:${key.name}`) || null;
      return [value];
    },
    async save({ key, data }) {
      inMemoryStore.set(`${key.kind}:${key.name}`, data);
    },
    async delete(key) {
      inMemoryStore.delete(`${key.kind}:${key.name}`);
    },
    createQuery(kind) {
      return { kind, _limit: null, limit(limit) { this._limit = limit; return this; } };
    },
    async runQuery(query) {
      const results = [];
      for (const [storageKey, value] of inMemoryStore.entries()) {
        const [entryKind] = storageKey.split(":");
        if (entryKind === query.kind) {
          results.push(value);
          if (query._limit && results.length >= query._limit) break;
        }
      }
      return [results];
    },
  };
}

function getDatastore() {
  if (datastore) return datastore;

  const env = {
    NODE_ENV: process.env.NODE_ENV || "",
    ENABLE_LOCAL_DATASTORE: process.env.ENABLE_LOCAL_DATASTORE || "",
  };
  console.log(
    JSON.stringify({
      severity: "DEBUG",
      service: "orderfood-api",
      event: "datastore_config",
      env,
      usingLocal: shouldUseLocalDatastore(),
    }),
  );

  if (shouldUseLocalDatastore()) {
    console.log(
      JSON.stringify({
        severity: "INFO",
        service: "orderfood-api",
        event: "datastore_local_fallback",
        message: "Using local in-memory datastore because local datastore is enabled or NODE_ENV is not production",
      }),
    );
    datastore = createLocalDatastore();
    return datastore;
  }

  try {
    const { Datastore } = require("@google-cloud/datastore");
    datastore = new Datastore();
    console.log(
      JSON.stringify({
        severity: "INFO",
        service: "orderfood-api",
        event: "datastore_connected",
        message: "Connected to Google Cloud Datastore",
      }),
    );
    return datastore;
  } catch (error) {
    console.error(
      JSON.stringify({
        severity: "ERROR",
        service: "orderfood-api",
        event: "datastore_init_failed",
        message: "Failed to initialize Google Datastore in production mode",
        error: String(error.message),
      }),
    );
    throw error;
  }
}

module.exports = {
  getDatastore,
};
