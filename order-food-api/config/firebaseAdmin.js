let firebaseAdmin = null;
let loadFailed = false;

function parseFirebaseAdminConfig() {
  const raw = String(process.env.FIREBASE_ADMIN_CONFIG || "").trim();
  if (!raw) return null;

  const jsonText = raw.startsWith("{")
    ? raw
    : Buffer.from(raw, "base64").toString("utf8");
  const config = JSON.parse(jsonText);

  if (typeof config.private_key === "string") {
    config.private_key = config.private_key.replace(/\\n/g, "\n");
  }

  return config;
}

function getFirebaseAdmin() {
  if (firebaseAdmin || loadFailed) return firebaseAdmin;

  try {
    const admin = require("firebase-admin");
    if (!admin.apps.length) {
      const serviceAccount = parseFirebaseAdminConfig();
      const firebaseProjectId =
        process.env.FIREBASE_PROJECT_ID ||
        serviceAccount?.project_id ||
        process.env.GCLOUD_PROJECT ||
        process.env.GOOGLE_CLOUD_PROJECT;

      admin.initializeApp(
        serviceAccount
          ? {
              credential: admin.credential.cert(serviceAccount),
              projectId: firebaseProjectId,
            }
          : firebaseProjectId
            ? { projectId: firebaseProjectId }
            : undefined,
      );
    }
    firebaseAdmin = admin;
  } catch (error) {
    loadFailed = true;
    console.warn(
      JSON.stringify({
        severity: "WARNING",
        service: "orderfood-api",
        event: "firebase_admin_unavailable",
        message: error.message,
      }),
    );
  }

  return firebaseAdmin;
}

module.exports = getFirebaseAdmin;
