const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/user");
const Employee = require("../models/employee");
const router = express.Router();

const JWT_SECRET = process.env.JWT_SECRET || "your_default_secret_key"; // Ensure this is stored in an environment variable

// In-memory store for active sessions (for demonstration purposes)
const activeSessions = {};

// Registration endpoint
router.post("/register", async (req, res) => {
  const { staffId, firstName, lastName, email, password } = req.body;

  try {
    console.log("Received a registration request");

    // Check if the employee exists
    const employee = await Employee.findOne({ staffId: staffId.trim() });
    if (!employee) {
      console.log("Employee not found");
      return res.status(404).json({ message: "Employee not found" });
    }

    // Check if the staffId already exists in the User model
    const existingUserByStaffId = await User.findOne({ staffId });
    if (existingUserByStaffId) {
      console.log("User with this staff ID already exists");
      return res.status(400).json({ message: "User with this staff ID already exists" });
    }

    // Check if the email already exists in the User model
    const existingUserByEmail = await User.findOne({ email });
    if (existingUserByEmail) {
      console.log("User with this email already exists");
      return res.status(400).json({ message: "User with this email already exists" });
    }

    // Create a new user
    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = new User({
      staffId,
      firstName,
      lastName,
      email,
      password: hashedPassword,
    });

    await newUser.save();
    console.log("User registered successfully");

    // Create a JWT payload
    const payload = {
      id: newUser._id,
      email: newUser.email,
      staffId: newUser.staffId,
      firstName: newUser.firstName,
      lastName: newUser.lastName,
    };

    // Generate JWT
    const token = jwt.sign(payload, JWT_SECRET, { expiresIn: "1h" });

    // Return token and staff_id in the response
    res.status(201).json({ message: "User registered successfully", token, staff_id: newUser.staffId });
  } catch (error) {
    console.error("Error registering user:", error);
    res.status(500).json({ message: "Error registering user" });
  }
});

// Login endpoint
router.post("/signin", async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    // Invalidate previous session
    if (activeSessions[user.staffId]) {
      console.log("Invalidating previous session for staffId: ${user.staffId}");
      delete activeSessions[user.staffId]; // Remove the previous session
    }

    // Create a JWT payload
    const payload = {
      id: user._id,
      email: user.email,
      staffId: user.staffId,
      firstName: user.firstName,
      lastName: user.lastName,
    };

    // Generate JWT
    const token = jwt.sign(payload, JWT_SECRET, { expiresIn: "1h" });

    // Store the new session
    activeSessions[user.staffId] = { token };

    // Return token and staff_id in the response
    res.status(200).json({ message: "Login successful", token, staff_id: user.staffId });
  } catch (error) {
    console.error("Server error during login:", error);
    res.status(500).json({ message: "Server error" });
  }
});

const authMiddleware = (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1]; // Extract token from Authorization header
  if (!token) {
    return res.status(401).json({ message: "Unauthorized, no token provided" });
  }

  console.log("Received token for verification:", token);

  try {
    // Verify JWT
    const decoded = jwt.verify(token, JWT_SECRET);
    console.log("Decoded token payload:", decoded);

    // Check for valid session
    const session = activeSessions[decoded.staffId];
    if (!session) {
      console.log("No active session found for staffId:", decoded.staffId);
      return res.status(401).json({ message: "Unauthorized, session not found" });
    }
    console.log(session.token);
    console.log(token);
    if (session.token !== token) {
      console.log("Token mismatch for staffId:", decoded.staffId);
      return res.status(401).json({ message: "Unauthorized, invalid session" });
    }

    req.user = decoded;
    next();
  } catch (error) {
    console.error("Unauthorized access attempt:", error);
    res.status(401).json({ message: "Unauthorized, invalid token" });
  }
};

router.post("/logout", authMiddleware, (req, res) => {
  const staffId = req.user.staffId;
  // delete activeSessions[staffId]; // Remove the active session

  res.status(200).json({ message: "Logged out successfully" });
});

// Example of a protected route
router.get("/protected", authMiddleware, (req, res) => {
  res.json({ message: "This is a protected route", user: req.user });
});

module.exports = router;