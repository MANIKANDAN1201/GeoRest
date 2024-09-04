// models/location.js
const mongoose = require("mongoose");

const locationSchema = new mongoose.Schema({
  staffId: { type: String, required: true }, // New field for staff ID
  latitude: { type: Number, required: true },
  longitude: { type: Number, required: true },
  timestamp: { type: Date, required: true },
});

const Location = mongoose.model("Location", locationSchema);

module.exports = Location;
