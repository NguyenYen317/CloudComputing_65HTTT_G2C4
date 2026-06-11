let firebaseAdmin = null;
let loadFailed = false;

function getFirebaseAdmin() {
  if (firebaseAdmin || loadFailed) return firebaseAdmin;

  try {
    const admin = require("firebase-admin");
    if (!admin.apps.length) {
      admin.initializeApp();
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
