const express = require("express");
const cors = require("cors");
const beachData = require("./beachData");
const admin = require("firebase-admin");
const dotenv = require("dotenv");

// Load environment variables
dotenv.config();

// Initialize Firebase Admin SDK
const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT
  ? JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)
  : {
      // Default credentials for development (replace with your own in production)
      type: "service_account",
      project_id: "beachsafteyappbpit",
      private_key_id: "your-private-key-id",
      private_key: "your-private-key",
      client_email: "your-client-email",
      client_id: "your-client-id",
      auth_uri: "https://accounts.google.com/o/oauth2/auth",
      token_uri: "https://oauth2.googleapis.com/token",
      auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
      client_x509_cert_url: "your-cert-url",
    };

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://beachsafteyappbpit-default-rtdb.firebaseio.com",
});

const database = admin.database();
const beachesRef = database.ref("beaches");

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Sync beach data to Firebase on server start
const syncBeachesToFirebase = async () => {
  try {
    const snapshot = await beachesRef.once("value");
    const existingData = snapshot.val();

    // Only initialize if data doesn't exist
    if (!existingData) {
      console.log("Initializing beach data in Firebase...");
      await beachesRef.set(beachData.beaches);
      console.log("Beach data synced to Firebase successfully");
    } else {
      console.log("Beach data already exists in Firebase");
    }
  } catch (error) {
    console.error("Error syncing data to Firebase:", error);
  }
};

// Function to evaluate beach safety based on conditions
function evaluateBeachSafety(waveHeight, oceanCurrents) {
  // Example thresholds - adjust based on your requirements
  const dangerousWaveHeight = 1.5;
  const dangerousCurrents = ["Strong", "Moderate to Strong"];

  if (waveHeight >= dangerousWaveHeight) return false;
  if (dangerousCurrents.some((current) => oceanCurrents.includes(current)))
    return false;

  return true;
}

// Routes
app.get("/api/beaches", async (req, res) => {
  try {
    // Get data from Firebase instead of direct import
    const snapshot = await beachesRef.once("value");
    const beaches = snapshot.val();
    res.json(beaches);
  } catch (error) {
    console.error("Error fetching beaches from Firebase:", error);
    res.status(500).json({ message: "Error fetching beaches" });
  }
});

app.get("/api/beaches/:id", async (req, res) => {
  try {
    const beachId = req.params.id;
    const snapshot = await beachesRef
      .orderByChild("id")
      .equalTo(beachId)
      .once("value");
    const beaches = snapshot.val();

    if (!beaches) {
      return res.status(404).json({ message: "Beach not found" });
    }

    // Get the first (and only) beach with the matching ID
    const beach = Object.values(beaches)[0];
    res.json(beach);
  } catch (error) {
    console.error("Error fetching beach from Firebase:", error);
    res.status(500).json({ message: "Error fetching beach" });
  }
});

app.get("/api/beaches/search", async (req, res) => {
  try {
    const { query } = req.query;
    const snapshot = await beachesRef.once("value");
    const allBeaches = snapshot.val();

    if (!query) {
      return res.json(allBeaches);
    }

    const searchResults = Object.values(allBeaches).filter(
      (beach) =>
        beach.name.toLowerCase().includes(query.toLowerCase()) ||
        beach.location.toLowerCase().includes(query.toLowerCase())
    );

    res.json(searchResults);
  } catch (error) {
    console.error("Error searching beaches in Firebase:", error);
    res.status(500).json({ message: "Error searching beaches" });
  }
});

// Update beach data
app.put("/api/beaches/:id", async (req, res) => {
  try {
    const beachId = req.params.id;
    const updatedData = req.body;

    // Validate incoming data
    if (!updatedData || !beachId) {
      return res.status(400).json({ message: "Invalid request data" });
    }

    // Find the beach reference by ID using orderByChild
    const snapshot = await beachesRef
      .orderByChild("id")
      .equalTo(beachId)
      .once("value");
    const beaches = snapshot.val();

    if (!beaches) {
      return res.status(404).json({ message: "Beach not found" });
    }

    // Get the Firebase key for this beach
    const firebaseKey = Object.keys(beaches)[0];
    const currentBeach = beaches[firebaseKey];

    // If wave height or ocean currents are being updated, recalculate safety
    if (
      updatedData.waveHeight !== undefined ||
      updatedData.oceanCurrents !== undefined
    ) {
      // Use updated values or fall back to current values
      const newWaveHeight = updatedData.waveHeight ?? currentBeach.waveHeight;
      const newOceanCurrents =
        updatedData.oceanCurrents ?? currentBeach.oceanCurrents;

      // Set the isSafe property based on conditions
      updatedData.isSafe = evaluateBeachSafety(newWaveHeight, newOceanCurrents);
      console.log(
        `Beach safety updated for ${beachId}: isSafe=${updatedData.isSafe}`
      );
    }

    // Update beach in Firebase using the correct Firebase key
    await beachesRef.child(firebaseKey).update(updatedData);

    res.json({
      message: "Beach updated successfully",
      beach: { ...currentBeach, ...updatedData, id: beachId },
    });
  } catch (error) {
    console.error("Error updating beach in Firebase:", error);
    res.status(500).json({ message: "Error updating beach" });
  }
});

// Check and fix database synchronization
app.get("/api/admin/sync-check", async (req, res) => {
  try {
    console.log("Starting database synchronization check...");

    // Get all beaches from Firebase
    const snapshot = await beachesRef.once("value");
    const beaches = snapshot.val();

    if (!beaches) {
      return res.status(404).json({ message: "No beaches found in database" });
    }

    let updatedCount = 0;
    let beachCount = 0;
    const updatedBeaches = [];

    // Process each beach
    const updatePromises = Object.entries(beaches).map(async ([key, beach]) => {
      beachCount++;

      // Validate beach data
      if (
        !beach.id ||
        !beach.name ||
        beach.waveHeight === undefined ||
        !beach.oceanCurrents
      ) {
        console.log(`Beach with key ${key} has invalid data:`, beach);
        return;
      }

      // Check safety status
      const expectedSafety = evaluateBeachSafety(
        beach.waveHeight,
        beach.oceanCurrents
      );

      // If safety status doesn't match the calculated value, update it
      if (beach.isSafe !== expectedSafety) {
        console.log(
          `Updating safety for beach ${beach.name} (${beach.id}): ${beach.isSafe} -> ${expectedSafety}`
        );

        await beachesRef.child(key).update({ isSafe: expectedSafety });
        updatedCount++;
        updatedBeaches.push({
          id: beach.id,
          name: beach.name,
          previousSafety: beach.isSafe,
          newSafety: expectedSafety,
          waveHeight: beach.waveHeight,
          oceanCurrents: beach.oceanCurrents,
        });
      }
    });

    // Wait for all updates to complete
    await Promise.all(updatePromises);

    res.json({
      success: true,
      message: `Database synchronization complete. Checked ${beachCount} beaches, updated ${updatedCount} safety values.`,
      updatedBeaches,
    });
  } catch (error) {
    console.error("Error during database sync check:", error);
    res
      .status(500)
      .json({ message: "Error checking database synchronization" });
  }
});

// Start server
app.listen(port, "0.0.0.0", async () => {
  console.log(`Server is running on port ${port}`);
  console.log(`Access the API at http://localhost:${port}/api`);
  console.log(`For Android emulator, use http://10.0.2.2:${port}/api`);

  // Sync beach data with Firebase on server start
  await syncBeachesToFirebase();
});
