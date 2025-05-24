#!/usr/bin/env node

/**
 * This script helps set up Firebase Admin SDK credentials
 * for the BeachSafe India server.
 */

const fs = require("fs");
const path = require("path");
const readline = require("readline");

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

console.log("\n=== BeachSafe India Firebase Setup ===\n");
console.log(
  "This script will help you configure Firebase Admin SDK credentials."
);
console.log(
  "You need to get your service account JSON from Firebase Console > Project Settings > Service Accounts\n"
);

const promptPath = () => {
  rl.question(
    "Enter the path to your Firebase service account JSON file\n(or press Enter to input JSON directly): ",
    (input) => {
      if (input.trim() === "") {
        promptManualJson();
      } else {
        try {
          const fullPath = path.resolve(input.trim());
          const fileContent = fs.readFileSync(fullPath, "utf8");
          let serviceAccount;

          try {
            serviceAccount = JSON.parse(fileContent);
            createEnvFile(JSON.stringify(serviceAccount));
          } catch (err) {
            console.error("\nError: The file does not contain valid JSON");
            promptPath();
          }
        } catch (err) {
          console.error(`\nError: Could not read file at ${input}`);
          promptPath();
        }
      }
    }
  );
};

const promptManualJson = () => {
  console.log("\nPlease paste your Firebase service account JSON below:");
  console.log("(Press Enter twice when done)\n");

  let jsonInput = "";
  let emptyLineCount = 0;

  rl.prompt();

  rl.on("line", (line) => {
    if (line.trim() === "") {
      emptyLineCount++;
      if (emptyLineCount >= 2) {
        try {
          const serviceAccount = JSON.parse(jsonInput);
          createEnvFile(JSON.stringify(serviceAccount));
          rl.close();
        } catch (err) {
          console.error("\nError: Invalid JSON format. Please try again.");
          jsonInput = "";
          emptyLineCount = 0;
          rl.prompt();
        }
      }
    } else {
      jsonInput += line;
      emptyLineCount = 0;
    }
  });
};

const createEnvFile = (serviceAccountJson) => {
  const envPath = path.join(__dirname, ".env");
  const envExamplePath = path.join(__dirname, ".env.example");

  let envContent;

  // Try to read existing .env first
  try {
    envContent = fs.readFileSync(envPath, "utf8");
  } catch (err) {
    // If .env doesn't exist, try to read from .env.example
    try {
      envContent = fs.readFileSync(envExamplePath, "utf8");
    } catch (err) {
      // If neither exists, create minimal content
      envContent = "# Server Configuration\nPORT=3000\n\n";
    }
  }

  // Update or add FIREBASE_SERVICE_ACCOUNT line
  if (envContent.includes("FIREBASE_SERVICE_ACCOUNT=")) {
    envContent = envContent.replace(
      /FIREBASE_SERVICE_ACCOUNT=.*/,
      `FIREBASE_SERVICE_ACCOUNT=${serviceAccountJson}`
    );
  } else {
    envContent += `\n# Firebase Configuration\nFIREBASE_SERVICE_ACCOUNT=${serviceAccountJson}\n`;
  }

  // Write to .env file
  fs.writeFileSync(envPath, envContent);

  console.log("\n✅ Firebase credentials have been saved to .env file");
  console.log("🚀 You can now start the server with: npm run dev\n");

  rl.close();
};

// Start the prompt
promptPath();
