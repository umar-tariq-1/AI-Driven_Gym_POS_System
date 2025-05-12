const express = require("express");
const { authorize } = require("../../middlewares/authorize");

const users = express.Router();

users.get("/trainers", authorize, async (req, res) => {
  const db = req.db;

  try {
    const [trainers] = await db.query(
      `SELECT id, firstName, lastName, gender, email FROM Users WHERE accType = 'Trainer'`
    );
    res.status(200).json(trainers);
  } catch (error) {
    console.error("Error fetching trainers:", error);
    res.status(500).json({ message: "Internal server error" });
  }
});

module.exports = users;
