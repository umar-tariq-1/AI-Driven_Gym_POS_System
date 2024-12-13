const express = require("express");
const nodemailer = require("nodemailer");
const bcrypt = require("bcrypt");

const sendOtp = express.Router();

sendOtp.post("/send", async (req, res) => {
  try {
    const email = req.body.email;

    if (!email) {
      return res.status(400).send({ message: "Email is required" });
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

sendOtp.post("/verify", async (req, res) => {
  try {
    const { enteredOTP, hashedOTP } = req.body;

    if (!enteredOTP || !hashedOTP) {
      return res
        .status(400)
        .send({ message: "Both Entered-OTP and Hashed-OTP are Required" });
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

module.exports = sendOtp;
