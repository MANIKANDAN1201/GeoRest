// geofence.js
const express = require("express");
const router = express.Router();

// Dummy notification function
function triggerNotification(message) {
  console.log("Notification triggered:", message);
}

// Middleware for geolocation check
const geolocationCheckMiddleware = (req, res, next) => {
  const userLocation = req.body;
  console.log("Received user location:", userLocation);

  const officeLocation = { latitude: 13.012449, longitude: 80.0003607 }; // Office location

  // Calculate the distance between the user and the office
  const distance = getDistanceFromLatLonInMeters(
    userLocation.latitude,
    userLocation.longitude,
    officeLocation.latitude,
    officeLocation.longitude
  );

  // Check if the distance is within 200 meters
  if (distance <= 200) {
    triggerNotification("User is within the office radius.");
    next(); // User is within the radius, proceed to the next middleware or route handler
  } else {
    triggerNotification("User is outside the office radius.");
    res.status(403).json({ message: "User is not within the office radius." });
  }
};

// Example route with geolocation check middleware
router.post("/mark-attendance", geolocationCheckMiddleware, (req, res) => {
  // Logic to mark attendance
  res.json({ message: "Attendance marked successfully!" });
});

// Function to calculate the distance between two geographic points using the Haversine formula
function getDistanceFromLatLonInMeters(lat1, lon1, lat2, lon2) {
  const R = 6371000; // Radius of the Earth in meters
  const dLat = (lat2 - lat1) * (Math.PI / 180); // Convert latitude difference to radians
  const dLon = (lon2 - lon1) * (Math.PI / 180); // Convert longitude difference to radians
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * (Math.PI / 180)) *
      Math.cos(lat2 * (Math.PI / 180)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const distance = R * c; // Distance in meters
  return distance;
}

module.exports = router;
