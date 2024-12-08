const express = require("express");
const bcrypt = require("bcrypt");
const { authorize } = require("../../middlewares/authorize");
const { validate, capitalize } = require("../../utils/validate");
const { findKeyWithEmptyStringValue } = require("../../utils/objectFunctions");

const editUser = express.Router();

editUser.put("/password", authorize, async (req, res) => {
  const db = req.db;
  const userId = req.userData.id;
  const userPassword = req.userData.password;

  const { oldPassword, newPassword } = req.body;

  if (!oldPassword || !newPassword) {
    return res
      .status(400)
      .send({ message: "Old password and new password are required." });
  }

  try {
    const validPassword = await bcrypt.compare(oldPassword, userPassword);
    if (!validPassword) {
      return res.status(401).send({ message: "Old password is incorrect." });
    }

    const isSamePassword = await bcrypt.compare(newPassword, userPassword);
    if (isSamePassword) {
      return res.status(400).send({
        message: "New password cannot be the same as the old password.",
      });
    }
    const validationError = validate(
      "Umar",
      "Tariq",
      "12345678910",
      newPassword,
      newPassword,
      "admin"
    );
    if (validationError) {
      return res.status(403).send({ message: validationError });
    }
    const salt = await bcrypt.genSalt(10);
    const hashedNewPassword = await bcrypt.hash(newPassword, salt);

    await db.query(
      "UPDATE gym_pos_system.Users SET password = ? WHERE id = ?",
      [hashedNewPassword, userId]
    );

    res.status(200).send({ message: "Password updated successfully." });
  } catch (error) {
    console.error("Error updating password: ", error);
    return res.status(500).send({ message: "Internal server error." });
  }
});

editUser.put("/info", authorize, async (req, res) => {
  const db = req.db;
  const userId = req.userData.id;
  const firstName = req.body.firstName.trim();
  const lastName = req.body.lastName.trim();
  const emptyKey = findKeyWithEmptyStringValue({ firstName, lastName });
  if (emptyKey !== null) {
    return res.status(422).send({
      message: `${capitalize(
        emptyKey.replace(/([A-Z])/g, " $1")
      )} must not be empty`,
    });
  }

  if (!firstName && !lastName) {
    return res
      .status(400)
      .send({ message: "First name or last name required." });
  }
  if (firstName) {
    var validationError1 = validate(
      firstName,
      "Tariq",
      "email@gmail.com",
      "+1234567890",
      "Qwe123",
      "Qwe123",
      "admin"
    );
  }
  if (lastName) {
    var validationError2 = validate(
      "Umar",
      lastName,
      "email@gmail.com",
      "+1234567890",
      "Qwe123",
      "Qwe123",
      "admin"
    );
  }

  if (validationError1) {
    return res.status(403).send({ message: validationError1 });
  }

  if (validationError2) {
    return res.status(403).send({ message: validationError2 });
  }

  try {
    const updates = {};

    const [foundUser] = await db.query(
      "SELECT firstName, lastName FROM gym_pos_system.Users WHERE id = ?",
      [userId]
    );
    const currentUser = foundUser[0];

    if (
      firstName &&
      firstName === currentUser.firstName &&
      lastName &&
      lastName === currentUser.lastName
    ) {
      return res.status(400).send({
        message: "New name cannot be the same as the current name.",
      });
    }

    if (firstName) updates.firstName = capitalize(firstName);
    if (lastName) updates.lastName = capitalize(lastName);

    const updateQuery = `
      UPDATE gym_pos_system.Users
      SET ${Object.keys(updates)
        .map((key) => `${key} = ?`)
        .join(", ")}
      WHERE id = ?
    `;

    const params = [...Object.values(updates), userId];
    await db.query(updateQuery, params);

    res.status(200).send({ message: "User info updated successfully." });
  } catch (error) {
    console.error("Error updating user info: ", error);
    return res.status(500).send({ message: "Internal server error." });
  }
});

module.exports = editUser;
