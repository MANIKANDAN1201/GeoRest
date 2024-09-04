// models/attendanceModel.js
const mongoose = require("mongoose");

// Attendance Schema
const attendanceSchema = new mongoose.Schema({
  staffId: { type: Number, required: true },
  time: { type: Date, required: true },
  location: { type: String, required: true },
  type: { type: String, enum: ["checkin", "checkout"], required: true },
});

// Create the model
const Attendance = mongoose.model("Attendance", attendanceSchema);

module.exports = Attendance;
