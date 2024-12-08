const express = require("express");
const { authorize } = require("../../middlewares/authorize");
const nodemailer = require("nodemailer");
const bcrypt = require("bcrypt");

const sendOtp = express.Router();

sendOtp.get("/", authorize, async (req, res) => {
  const userData = req.userData;
  const otp = Math.floor(100000 + Math.random() * 900000);
  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: "gympossystem@gmail.com",
      pass: "zmyf jhxf pojr ltjd",
    },
  });

  const mailOptions = {
    from: "Gym POS System",
    to: userData.email,
    subject: `Email verification OTP: ${otp}`,
    text: `We received a request to verify your email for Gym Point of Sales System registration process.\n\nYour one time password for email verification is ${otp}.\n\nWarning: Don't share your one time password with anyone.\n\nIf you didn't try to register with Gym Point of Sales System, you can safely ignore this email.\n\nThanks`,
  };

  // transporter.sendMail(mailOptions, function (error, info) {
  //   if (error) {
  //     console.log("Error:", error);
  //     res
  //       .status(500)
  //       .send({ error: "Error sending OTP mail. Please try again later." });
  //     return;
  //   }
  // });
  const salt = await bcrypt.genSalt(10);
  const hashedOTP = await bcrypt.hash(toString(otp), salt);
  res.status(200).send({ hashedOTP });
});

module.exports = sendOtp;
