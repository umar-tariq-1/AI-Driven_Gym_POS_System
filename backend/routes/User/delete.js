const express = require("express");
const bcrypt = require("bcrypt");
const { authorize } = require("../../middlewares/authorize");

const deleteUser = express.Router();

deleteUser.delete("/", authorize, async (req, res) => {
  const db = req.db;
  const authToken = req.headers["auth-token"];
  const { password } = req.body;
  const userId = req.userData.id;
  const userPassword = req.userData.password;

  if (!authToken || !password) {
    return res
      .status(403)
      .send({ message: "Token and password are required." });
  }

  if (!userId) {
    return res.status(401).send({ message: "Invalid token." });
  }

  try {
    const validPassword = await bcrypt.compare(password, userPassword);
    if (!validPassword) {
      return res.status(401).send({ message: "Incorrect password." });
    }

    // Proceed to delete the user
    await db.query("DELETE FROM gym_pos_system.Users WHERE id = ?", [userId]);

    res.status(200).send({ message: "User deleted successfully." });
  } catch (error) {
    console.error("Error deleting user: ", error);
    return res.status(500).send({ message: "Internal server error." });
  }
});

module.exports = deleteUser;
