const express = require("express");
const nodemailer = require("nodemailer");
const bcrypt = require("bcrypt");
const { findKeyWithEmptyStringValue } = require("../../utils/objectFunctions");
const { validate } = require("../../utils/validate");

const OTP = express.Router();

OTP.post("/", async (req, res) => {
  try {
    const email = req.body.email?.trim();
    const db = req.db;

    if (!email) {
      return res.status(403).send({ message: "Email is required" });
    }

    if (!isValidEmail(email)) {
      return res.status(400).send({ message: "Invalid Email" });
    }

    const [foundUser] = await db.query(
      "SELECT * FROM gym_pos_system.Users WHERE email = ?",
      [email]
    );

    if (foundUser.length == 0) {
      return res
        .status(404)
        .json({ message: "No user registered with this email" });
    }

    const otp = Math.floor(100000 + Math.random() * 900000);
    console.log("OTP:", otp);
    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: "gympossystem@gmail.com",
        pass: "zmyf jhxf pojr ltjd",
      },
    });

    const mailOptions = {
      from: "Gym POS System <gympossystem@gmail.com>",
      to: email,
      subject: `Email verification OTP: ${otp}`,
      text: `We received a request to change your account password for Gym Point of Sales System.\n\nYour one time password for verification is ${otp}.\n\nWarning: Don't share your one time password with anyone.\n\nIf you didn't try to change password for Gym Point of Sales System account, you can safely ignore this email.\n\nThanks`,
    };

    // const info = await transporter.sendMail(mailOptions);

    // if (!info) {
    //   return res.status(500).send({ message: "Failed to send OTP over Email" });
    // }
    const salt = await bcrypt.genSalt(10);
    const hashedOTP = await bcrypt.hash(otp.toString(), salt);
    res.status(200).send({
      message: "OTP Sent Successfully over Email",
      hashedOTP,
    });
  } catch (error) {
    console.log(error);
    if (error.code === "EENVELOPE") {
      res.status(400).send({ message: "Invalid Email Address" });
    } else if (error.code === "EAUTH") {
      res.status(500).send({ message: "Internal Server Error" });
    } else {
      res.status(500).send({ message: "An unexpected error occurred" });
    }
  }
});

OTP.post("/verify", async (req, res) => {
  try {
    const { enteredOTP, hashedOTP } = req.body;

    if (!enteredOTP || !hashedOTP) {
      return res.status(400).send({
        message:
          "Incomplete Info" /* "Both Entered-OTP and Hashed-OTP are Required" */,
      });
    }

    const isMatch = await bcrypt.compare(enteredOTP, hashedOTP);

    if (isMatch) {
      return res.status(200).send({ message: "OTP Verified Successfully" });
    } else {
      return res.status(400).send({ message: "Invalid OTP" });
    }
  } catch (error) {
    res.status(500).send({ message: "An Unexpected Error Occurred" });
  }
});

OTP.put("/update-password", async (req, res) => {
  const db = req.db;
  try {
    var userData = {
      email: req.body?.email.trim(),
      password: req.body?.password,
      confirmPassword: req.body?.confirmPassword,
    };
  } catch {
    return res.status(403).send({ message: "Information is not complete" });
  }

  // Check for empty fields
  const emptyKey = findKeyWithEmptyStringValue(userData);
  if (emptyKey !== null) {
    return res.status(422).send({
      message: `${capitalize(
        emptyKey.replace(/([A-Z])/g, " $1")
      )} must not be empty`,
    });
  }

  try {
    // Validate user input
    const validationError = validate(
      "Umar",
      "Tariq",
      userData.email,
      "+1234567890",
      userData.password,
      userData.confirmPassword,
      "Admin",
      "Male"
    );

    if (validationError) {
      return res.status(403).send({ message: validationError });
    }

    // Check if email exists in the database
    const [existingUser] = await db.query(
      "SELECT * FROM gym_pos_system.Users WHERE email = ?",
      [userData.email]
    );

    if (existingUser.length == 0) {
      return res
        .status(404)
        .send({ error: "No user registered with this email" });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(userData.password, salt);
    userData.password = hashedPassword;

    await db.query(
      "UPDATE gym_pos_system.Users SET password = ? WHERE email = ?",
      [userData.password, userData.email]
    );

    res.status(200).send({ message: "Password Updated Successfully" });
  } catch (error) {
    console.log(error);
    res
      .status(500)
      .send({ message: "An error occurred while updating the password" });
  }
});

function isValidEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

module.exports = OTP;
