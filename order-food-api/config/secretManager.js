const DEFAULT_SECRET_MAP = {
  GOOGLE_MAPS_API_KEY: "GOOGLE_MAPS_API_KEY",
  FIREBASE_ADMIN_CONFIG: "FIREBASE_ADMIN_CONFIG",
  JWT_SECRET: "JWT_SECRET",
  FCM_SERVER_KEY: "FCM_SERVER_KEY",
  BIGQUERY_DATASET_ID: "BIGQUERY_DATASET",
  BIGQUERY_TABLE_ID: "BIGQUERY_ORDER_EVENTS_TABLE",
  PUBSUB_ORDER_TOPIC: "PUBSUB_ORDER_EVENTS_TOPIC",
  CLOUD_STORAGE_BUCKET: "FOOD_IMAGE_BUCKET",
  ADMIN_EMAILS: "ADMIN_EMAILS",
  ML_SECRET_KEY: "ML_SECRET_KEY",
};

function isEnabled() {
  return String(process.env.ENABLE_SECRET_MANAGER || "").toLowerCase() === "true";
}

function getProjectId() {
  return (
    process.env.SECRET_MANAGER_PROJECT_ID ||
    process.env.GOOGLE_CLOUD_PROJECT ||
    process.env.GCLOUD_PROJECT ||
    process.env.GCP_PROJECT ||
    ""
  );
}

function parseCustomSecretMap() {
  const raw = String(process.env.SECRET_MANAGER_SECRET_MAP || "").trim();
  if (!raw) return {};

  return raw.split(",").reduce((map, pair) => {
    const [secretName, envName] = pair.split("=").map((item) => item.trim());
    if (secretName && envName) map[secretName] = envName;
    return map;
  }, {});
}

function shouldOverrideEnv() {
  return String(process.env.SECRET_MANAGER_OVERRIDE_ENV || "").toLowerCase() === "true";
}

async function accessSecretValue(client, projectId, secretName) {
  const version = process.env.SECRET_MANAGER_VERSION || "latest";
  const name = `projects/${projectId}/secrets/${secretName}/versions/${version}`;
  const [response] = await client.accessSecretVersion({ name });
  return response.payload?.data?.toString("utf8") || "";
}

async function loadSecretsIntoEnv() {
  if (!isEnabled()) {
    return { enabled: false, loaded: [], skipped: [] };
  }

  const projectId = getProjectId();
  if (!projectId) {
    console.warn(
      JSON.stringify({
        severity: "WARNING",
        service: "orderfood-api",
        event: "secret_manager_skipped",
        reason: "missing_project_id",
      }),
    );
    return { enabled: true, loaded: [], skipped: [] };
  }

  let SecretManagerServiceClient;
  try {
    ({ SecretManagerServiceClient } = require("@google-cloud/secret-manager"));
  } catch (error) {
    console.warn(
      JSON.stringify({
        severity: "WARNING",
        service: "orderfood-api",
        event: "secret_manager_dependency_missing",
        error: error.message,
      }),
    );
    return { enabled: true, loaded: [], skipped: [] };
  }

  const client = new SecretManagerServiceClient();
  const secretMap = { ...DEFAULT_SECRET_MAP, ...parseCustomSecretMap() };
  const overrideEnv = shouldOverrideEnv();
  const loaded = [];
  const skipped = [];

  for (const [secretName, envName] of Object.entries(secretMap)) {
    if (!overrideEnv && process.env[envName]) {
      skipped.push({ secretName, envName, reason: "env_already_set" });
      continue;
    }

    try {
      const value = await accessSecretValue(client, projectId, secretName);
      if (!value) {
        skipped.push({ secretName, envName, reason: "empty_secret" });
        continue;
      }
      process.env[envName] = value;
      loaded.push({ secretName, envName });
    } catch (error) {
      skipped.push({ secretName, envName, reason: error.message });
      console.warn(
        JSON.stringify({
          severity: "WARNING",
          service: "orderfood-api",
          event: "secret_manager_secret_skipped",
          secretName,
          envName,
          error: error.message,
        }),
      );
    }
  }

  console.log(
    JSON.stringify({
      severity: "INFO",
      service: "orderfood-api",
      event: "secret_manager_loaded",
      loaded: loaded.map((item) => item.envName),
      skipped: skipped.map((item) => item.envName),
    }),
  );

  return { enabled: true, loaded, skipped };
}

module.exports = {
  DEFAULT_SECRET_MAP,
  loadSecretsIntoEnv,
};
