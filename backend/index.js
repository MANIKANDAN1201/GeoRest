const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const bodyParser = require("body-parser");

// Import routes
const authRoutes = require("./routes/auth");
const locationRoutes = require("./routes/location");
const geofenceRoutes = require("./routes/geofence"); // Correct import path
const suggestLocationRoutes = require("./routes/suggestLocation");
const attendanceRoutes = require("./routes/attendanceRoutes");
// Initialize Express app
const app = express();

// Middleware
app.use(bodyParser.json());
app.use(cors());

// Connect to MongoDB
mongoose
  .connect("mongodb://localhost:27017/geolocate", {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => console.log("MongoDB connected..."))
  .catch((err) => console.log(err));

// Use routes
app.use("/api/auth", authRoutes);
app.use("/api/location", locationRoutes);
app.use("/api/geofence", geofenceRoutes); // Use the geofence route
app.use("/api/offsite", suggestLocationRoutes);
app.use("/api/attendance", attendanceRoutes);
// Start the server
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
