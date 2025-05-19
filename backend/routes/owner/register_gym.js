const express = require("express");
const { authorize } = require("../../middlewares/authorize");

const ownerRegisterGym = express.Router();

ownerRegisterGym.post("/", authorize, async (req, res) => {
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

    res.status(200).send({ message: "Gym registered successfully" });
  } catch (error) {
    console.error("Error registering gym:", error);
    res.status(500).send({ message: "Internal server error" });
  }
});

ownerRegisterGym.get("/", authorize, async (req, res) => {
  const db = req.db;
  const ownerId = req.userData?.id;

  try {
    const [gyms] = await db.query(
      `SELECT id AS gymId, gymName, gymLocation
         FROM Gyms
        WHERE ownerId = ?`,
      [ownerId]
    );

    const gymData = await Promise.all(
      gyms.map(async (gym) => {
        const [trainers] = await db.query(
          `SELECT u.id, u.firstName, u.lastName
             FROM gymTrainers gt
             JOIN Users u ON u.id = gt.trainerId
            WHERE gt.gymId = ?`,
          [gym.gymId]
        );

        return {
          gymId: gym.gymId,
          gymName: gym.gymName,
          gymLocation: gym.gymLocation,
          trainers: trainers,
        };
      })
    );

    const [allTrainers] = await db.query(
      `SELECT id, firstName, lastName, gender, email
         FROM Users
        WHERE accType = 'Trainer'`
    );

    res.status(200).json({
      gymData,
      trainersData: allTrainers,
    });
  } catch (error) {
    console.error("Error fetching gyms and trainers data:", error);
    res.status(500).json({ message: "Internal server error" });
  }
});

module.exports = ownerRegisterGym;
