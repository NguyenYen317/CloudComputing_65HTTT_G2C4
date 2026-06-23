const { loadSecretsIntoEnv } = require("./config/secretManager");

async function startServer() {
  await loadSecretsIntoEnv();

  const app = require("./app");
  const { PORT } = require("./config/env");

  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

startServer().catch((error) => {
  console.error(
    JSON.stringify({
      severity: "ERROR",
      service: "orderfood-api",
      event: "server_start_failed",
      error: error.message,
    }),
  );
  process.exit(1);
});
