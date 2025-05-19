const express = require("express");
const { authorize } = require("../../middlewares/authorize");

const trainerRegisterGym = express.Router();

trainerRegisterGym.get("/gyms", authorize, async (req, res) => {
  const trainerId = req.userData.id;
  const db = req.db;
  if (!trainerId) {
    return res.status(400).json({ message: "Trainer ID is required" });
  }
  try {
    const gymIdsResult = await db.query(
      `SELECT gymId FROM gymtrainers WHERE trainerId = ?`,
      [trainerId]
    );
    const gymIds = gymIdsResult[0].map((row) => row.gymId);
    if (gymIds.length === 0) {
      return res.status(200).json({ gyms: [] });
    }
    const placeholders = gymIds.map(() => "?").join(", ");

    const gyms = await db.query(
      `SELECT id, gymName, gymLocation FROM gyms WHERE id IN (${placeholders})`,
      gymIds
    );
    res.status(200).json({ gyms: gyms[0] });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Error fetching gyms" });
  }
});

module.exports = trainerRegisterGym;
