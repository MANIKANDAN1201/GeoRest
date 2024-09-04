const mongoose = require("mongoose");

const offsiteLocationSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  latitude: {
    type: Number,
    required: true,
  },
  longitude: {
    type: Number,
    required: true,
  },
  radius: {
    type: Number,
    required: true, // Radius in meters
  },
});

module.exports = mongoose.model("OffsiteLocation", offsiteLocationSchema);
