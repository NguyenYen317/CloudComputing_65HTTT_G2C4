const path = require("path");
const { execFile } = require("child_process");
const { pythonBin } = require("../config/env");

function runPython(scriptName, options = {}) {
  const rootDir = path.join(__dirname, "..");
  const scriptPath = path.join(rootDir, "ml", scriptName);

  return new Promise((resolve, reject) => {
    execFile(
      pythonBin,
      [scriptPath],
      { cwd: rootDir, timeout: options.timeout || 120000 },
      (error, stdout, stderr) => {
        if (error) {
          error.message = [error.message, stderr].filter(Boolean).join("\n");
          reject(error);
          return;
        }
        resolve({ stdout, stderr });
      },
    );
  });
}

module.exports = runPython;
