const mongoose = require("mongoose");

const employeeSchema = new mongoose.Schema({
  staffId: { type: String, required: true, unique: true },
  FullName: { type: String, required: true, unique: true },
  Email: { type: String, required: true, unique: true },
  Gender: { type: String, required: true, unique: true },
  ContactNumber: { type: Number, required: true, unique: true },
  OfficeID: { type: Number, required: true, unique: true },
  Designation: { type: String, required: true, unique: true },
  photo: { type: String, required: true, unique: true },
});

module.exports = mongoose.model("Employee", employeeSchema);
