const express = require("express");
const bcrypt = require("bcrypt");
const { findKeyWithEmptyStringValue } = require("../../utils/objectFunctions");
const { capitalize } = require("../../utils/validate");
const { validate } = require("../../utils/validate");
const { createToken } = require("../../utils/token");

const register = express.Router();

register.post("/", async (req, res) => {
  const db = req.db;
  try {
    var userData = {
      firstName: req.body?.firstName.trim(),
      lastName: req.body?.lastName.trim(),
      phone: req.body?.phone.trim(),
      password: req.body?.password,
      confirmPassword: req.body?.confirmPassword,
      accType: req.body?.accType.trim(),
      gender: req.body?.gender.trim(),
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

  // Validate user input
  const validationError = validate(
    userData.firstName,
    userData.lastName,
    userData.phone,
    userData.password,
    userData.confirmPassword,
    userData.accType,
    userData.gender
  );

  if (validationError) {
    return res.status(403).send({ message: validationError });
  }

  // Check if user already exists
  try {
    const [existingUser] = await db.query(
      "SELECT * FROM gym_pos_system.Users WHERE phone = ?",
      [userData.phone]
    );

    if (existingUser.length > 0) {
      return res.status(409).send({ message: "User already exists" });
    }
  } catch (error) {
    console.error("Error checking user existence: ", error);
    return res.status(500).send({ message: "Internal server error" });
  }

  // Hash the password before storing in db
  const salt = await bcrypt.genSalt(10);
  const hashedPassword = await bcrypt.hash(userData.password, salt);
  userData.password = hashedPassword;

  // Insert user into MySQL database
  try {
    const insertQuery = `
      INSERT INTO gym_pos_system.Users (firstName, lastName, gender, phone, password, accType)
      VALUES (?, ?, ?, ?, ?, ?)
    `;

    const [result] = await db.query(insertQuery, [
      capitalize(userData.firstName),
      capitalize(userData.lastName),
      userData.gender,
      userData.phone,
      userData.password,
      userData.accType,
    ]);

    const token = createToken(result.insertId, "365d");
    var tokenExpirationTime =
      Date.now() + 1000 * 60 * 60 * 24 * 365 - 1000 * 30;

    res.status(200).send({
      message: "User registered and logged in successfully",
      isLoggedIn: true,
      token,
      tokenExpirationTime,
      data: {
        firstName: capitalize(userData.firstName),
        lastName: capitalize(userData.lastName),
        gender: userData.gender,
        phone: userData.phone,
        accType: userData.accType,
      },
    });
  } catch (error) {
    console.error("Error registering user: ", error);
    return res.status(500).send({ message: "Internal server error" });
  }
});

module.exports = register;
