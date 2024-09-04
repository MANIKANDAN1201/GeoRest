const express = require("express");
const router = express.Router();
const OffsiteLocation = require("../models/offsiteLocation");
// Haversine Distance Utility Function
function haversineDistance(lat1, lon1, lat2, lon2) {
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

// Route to suggest location
router.post("/suggestLocation", async (req, res) => {
  const { latitude, longitude } = req.body;

  if (latitude == null || longitude == null) {
    return res
      .status(400)
      .json({ message: "Latitude and longitude are required" });
  }

  try {
    // Find all locations from the database
    console.log("Fetching locations from database...");

    // Find all locations from the database
    const locations = await OffsiteLocation.find().exec();
    console.log("Locations fetched:", locations);

    if (locations.length === 0) {
      return res
        .status(404)
        .json({ message: "No locations found in the database" });
    }
    let suggestedLocation = null;
    // Check each location to see if it is within the radius
    for (const location of locations) {
      const distance = haversineDistance(
        latitude,
        longitude,
        location.latitude,
        location.longitude
      );
      console.log(suggestedLocation);
      console.log(distance);
      // Check if the distance is within the radius of the location
      if (distance <= location.radius) {
        suggestedLocation = location;
        break;
      }
    }

    if (suggestedLocation) {
      return res.json({ suggestedLocation });
    } else {
      return res
        .status(404)
        .json({ message: "No location found within the radius" });
    }
  } catch (err) {
    return res
      .status(500)
      .json({ message: "Internal server error", error: err });
  }
});

module.exports = router;
