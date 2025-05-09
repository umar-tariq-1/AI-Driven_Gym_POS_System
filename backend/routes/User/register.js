const express = require("express");
const bcrypt = require("bcrypt");
const { findKeyWithEmptyStringValue } = require("../../utils/objectFunctions");
const { capitalize } = require("../../utils/validate");
const { validate } = require("../../utils/validate");
const nodemailer = require("nodemailer");
const { createToken } = require("../../utils/token");

const register = express.Router();

register.post("/", async (req, res) => {
  const db = req.db;
  try {
    var userData = {
      firstName: req.body?.firstName.trim(),
      lastName: req.body?.lastName.trim(),
      email: req.body?.email.trim(),
      password: req.body?.password,
      confirmPassword: req.body?.confirmPassword,
      accType: req.body?.accType.trim(),
      gender: req.body?.gender.trim(),
      dob: req.body?.dob,
    };
  } catch (error) {
    console.log("Error extracting user data: ", error);
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
    userData.phone = req.body?.phone.trim();
  } catch (error) {
    console.log("Error extracting user data: ", error);
    return res.status(403).send({ message: "Information is not complete" });
  }

  // Validate user input
  const validationError = validate(
    userData.firstName,
    userData.lastName,
    userData.email,
    userData.phone,
    userData.password,
    userData.confirmPassword,
    userData.accType,
    userData.gender
  );

  if (validationError) {
    return res.status(403).send({ message: validationError });
  }

  try {
    const [existingUser] = await db.query(
      `SELECT * FROM gym_pos_system.Users WHERE email = ?${
        userData.phone == "" ? "" : " OR phone = ?"
      }`,
      userData.phone == "" ? [userData.email] : [userData.email, userData.phone]
    );

    if (existingUser.length > 0) {
      return res.status(409).send({
        message:
          existingUser[0].email === userData.email
            ? "Account already registered with this email"
            : "Account already registered with this phone",
      });
    }
  } catch (error) {
    console.log("Error checking user existence: ", error);
    return res.status(500).send({ message: "Internal server error" });
  }

  const salt = await bcrypt.genSalt(10);
  const hashedPassword = await bcrypt.hash(userData.password, salt);
  userData.password = hashedPassword;

  try {
    const insertQuery = `
  INSERT INTO gym_pos_system.Users (firstName, lastName, gender, email, phone, password, accType, dob)
  VALUES (?, ?, ?, ?, ?, ?, ?, ?)
`;

    const [result] = await db.query(insertQuery, [
      capitalize(userData.firstName),
      capitalize(userData.lastName),
      userData.gender,
      userData.email,
      userData.phone === "" ? null : userData.phone,
      userData.password,
      userData.accType,
      userData.dob,
    ]);

    const insertedData = {
      ...userData,
      id: result.insertId,
    };

    delete insertedData.password;

    const authToken = createToken(result.insertId, "365d");
    const tokenExpirationTime =
      Date.now() + 1000 * 60 * 60 * 24 * 365 - 1000 * 30;

    res.status(200).send({
      message: "User registered and signed in successfully",
      isLoggedIn: true,
      authToken,
      tokenExpirationTime,
      data: insertedData,
    });
  } catch (error) {
    console.log("Error registering user: ", error);
    return res.status(500).send({ message: "Internal server error" });
  }
});

register.post("/otp", async (req, res) => {
  try {
    const email = req.body.email?.trim();

    if (!email) {
      return res.status(400).send({ message: "Email is required" });
    }

    if (!isValidEmail(email)) {
      return res.status(400).send({ message: "Invalid Email" });
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
      text: `We received a request to verify your email for Gym Point of Sales System registration process.\n\nYour one time password for email verification is ${otp}.\n\nWarning: Don't share your one time password with anyone.\n\nIf you didn't try to register with Gym Point of Sales System, you can safely ignore this email.\n\nThanks`,
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

function isValidEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

module.exports = register;
