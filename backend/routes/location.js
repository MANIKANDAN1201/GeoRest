// routes/location.js
const express = require("express");
const Location = require("../models/location");
const router = express.Router();

// Define geofencing coordinates (example coordinates, replace with your admin's geofencing coordinates)
const GEO_FENCE = {
  latitude: 37.7749, // Admin's geofence latitude
  longitude: -122.4194, // Admin's geofence longitude
  radius: 1000, // Radius in meters
};

// Function to calculate distance between two points
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371e3; // Earth radius in meters
  const φ1 = (lat1 * Math.PI) / 180;
  const φ2 = (lat2 * Math.PI) / 180;
  const Δφ = ((lat2 - lat1) * Math.PI) / 180;
  const Δλ = ((lon2 - lon1) * Math.PI) / 180;

  const a =
    Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
    Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return R * c; // Distance in meters
}

// Endpoint to receive location data
router.post("/", async (req, res) => {
  const { staffId, latitude, longitude, timestamp } = req.body;

  try {
    // Save location to database
    const location = new Location({ staffId, latitude, longitude, timestamp });
    await location.save();

    // Check if the location is within the geofence
    const distance = calculateDistance(
      GEO_FENCE.latitude,
      GEO_FENCE.longitude,
      latitude,
      longitude
    );

    if (distance <= GEO_FENCE.radius) {
      // Mark attendance logic here
      res
        .status(200)
        .json({ message: "Location is within geofence. Attendance marked." });
    } else {
      res.status(200).json({ message: "Location is outside geofence." });
    }
  } catch (error) {
    res.status(500).json({ message: "Error saving location" });
  }
});

module.exports = router;
