const express = require("express");
const { authorize } = require("../../middlewares/authorize");

const ownerRegisterGym = express.Router();

ownerRegisterGym.post("/register-gym", authorize, async (req, res) => {
  const db = req.db;
  const ownerId = req.userData?.id;
  const { gymName, gymLocation, trainerIds } = req.body;

  if (!gymName || !gymLocation || !Array.isArray(trainerIds)) {
    return res
      .status(400)
      .send({ message: "Invalid or incomplete request body" });
  }

  try {
    const [gymResult] = await db.query(
      `INSERT INTO Gyms (gymName, gymLocation, ownerId) VALUES (?, ?, ?)`,
      [gymName.trim(), gymLocation.trim(), ownerId]
    );

    const gymId = gymResult.insertId;

    if (trainerIds.length > 0) {
      const trainerInsertValues = trainerIds.map((trainerId) => [
        gymId,
        trainerId,
      ]);
      await db.query(`INSERT INTO gymTrainers (gymId, trainerId) VALUES ?`, [
        trainerInsertValues,
      ]);
    }

    res.status(200).send({ message: "Gym registered successfully", gymId });
  } catch (error) {
    console.error("Error registering gym:", error);
    res.status(500).send({ message: "Internal server error" });
  }
});

module.exports = ownerRegisterGym;
