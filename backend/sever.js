const express = require("express");
const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
const bodyParser = require("body-parser");
const cors = require("cors");
const nodemailer = require("nodemailer"); // Add nodemailer

// Initialize Express app
const app = express();

// Middleware
app.use(bodyParser.json());
app.use(cors());

// Connect to MongoDB
mongoose
  .connect("mongodb://localhost:27017/yourdatabase", {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => console.log("MongoDB connected..."))
  .catch((err) => console.log(err));

// Define a User schema
const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  isAdmin: { type: Boolean, default: false }, // Admin flag
});

// Create a User model
const User = mongoose.model("User", userSchema);

// Configure nodemailer
const transporter = nodemailer.createTransport({
  service: "Gmail", // or another email service
  auth: {
    user: "youremail@gmail.com", // Replace with your email
    pass: "yourpassword", // Replace with your email password
  },
});

// Admin login endpoint
app.post("/admin/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    // Find admin user by email
    const user = await User.findOne({ email: email, isAdmin: true });

    if (user) {
      // Check if password matches
      const isMatch = await bcrypt.compare(password, user.password);
      if (isMatch) {
        res.status(200).json({ message: "Admin login successful" });
      } else {
        res.status(401).json({ message: "Invalid credentials" });
      }
    } else {
      res.status(401).json({ message: "Invalid credentials" });
    }
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});

// Route to send login credentials to a user via email
app.post("/admin/send-credentials", async (req, res) => {
  const { userEmail, tempPassword } = req.body;

  try {
    // Hash the temporary password
    const hashedPassword = await bcrypt.hash(tempPassword, 10);

    // Check if the user exists
    let user = await User.findOne({ email: userEmail });

    if (!user) {
      // If user doesn't exist, create one
      user = new User({ email: userEmail, password: hashedPassword });
      await user.save();
    } else {
      // If user exists, update the password
      user.password = hashedPassword;
      await user.save();
    }

    // Send the email
    const mailOptions = {
      from: "youremail@gmail.com",
      to: userEmail,
      subject: "Your Login Credentials",
      text: `Your login credentials:\nEmail: ${userEmail}\nPassword: ${tempPassword}`,
    };

    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        return res.status(500).json({ message: "Error sending email" });
      } else {
        res.status(200).json({ message: "Credentials sent successfully" });
      }
    });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});

// Login endpoint for users
app.post("/signin", async (req, res) => {
  const { email, password } = req.body;

  try {
    // Find user by email
    const user = await User.findOne({ email: email });

    if (user) {
      // Check if password matches
      const isMatch = await bcrypt.compare(password, user.password);
      if (isMatch) {
        res.status(200).json({ message: "Login successful" });
      } else {
        res.status(401).json({ message: "Invalid credentials" });
      }
    } else {
      res.status(401).json({ message: "Invalid credentials" });
    }
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});

// Start the server
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
