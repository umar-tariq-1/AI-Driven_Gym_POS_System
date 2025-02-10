const express = require("express");
const { authorize } = require("../../middlewares/authorize");

const client = express.Router();

client.get("/", authorize, async (req, res) => {
  const db = req.db;
  const userData = req.userData;

  try {
    const userId = userData.id;

    const query = `
    SELECT 
      TrainerClasses.*, 
      JSON_OBJECT(
        'firstName', Users.firstName,
        'lastName', Users.lastName
      ) AS trainer,
      EXISTS (
        SELECT 1 
        FROM registeredclasses 
        WHERE registeredclasses.clientId = ? 
          AND registeredclasses.classId = TrainerClasses.id
      ) AS isAlreadyRegistered,
      (TrainerClasses.maxParticipants - 
        (SELECT COUNT(*) 
         FROM registeredclasses 
         WHERE registeredclasses.classId = TrainerClasses.id)
      ) AS remainingSeats
    FROM TrainerClasses
    JOIN gym_pos_system.users AS Users
    ON TrainerClasses.trainerId = Users.id;
  `;

    const classes = await db.query(query, [userId]);

    return res.status(200).send({ success: true, data: classes[0] });
  } catch (error) {
    console.error(error?.message);
    return res
      .status(500)
      .send({ success: false, message: "Internal Server Error" });
  }
});

client.post("/register", authorize, async (req, res) => {
  const db = req.db;
  const userData = req.userData;

  try {
    const clientId = userData.id;
    const classId = req.body.classId;

    const insertQuery = `
      INSERT INTO registeredclasses (clientId, classId)
      VALUES (?, ?)
      ON DUPLICATE KEY UPDATE registrationDateTime = CURRENT_TIMESTAMP;
    `;

    await db.query(insertQuery, [clientId, classId]);

    return res
      .status(200)
      .send({ success: true, message: "Registered Successfully" });
  } catch (error) {
    console.error(error?.message);
    return res
      .status(500)
      .send({ success: false, message: "Internal Server Error" });
  }
});

client.get("/registered-classes", authorize, async (req, res) => {
  const db = req.db;
  const userData = req.userData;

  try {
    const userId = userData.id;

    const query = `
      SELECT 
        *
      FROM TrainerClasses
      JOIN registeredclasses 
        ON TrainerClasses.id = registeredclasses.classId
      WHERE registeredclasses.clientId = ?;
    `;

    const classes = await db.query(query, [userId]);

    return res.status(200).send({ success: true, data: classes[0] });
  } catch (error) {
    console.error(error?.message);
    return res
      .status(500)
      .send({ success: false, message: "Internal Server Error" });
  }
});

client.get("/is-streaming/:classId", authorize, async (req, res) => {
  const db = req.db;
  const { classId } = req.params;

  if (!classId) {
    return res
      .status(400)
      .send({ success: false, message: "classId is required" });
  }

  try {
    const query = `
      SELECT isStreaming 
      FROM TrainerClasses 
      WHERE id = ?;
    `;
    const result = await db.query(query, [classId]);

    if (result[0].length === 0) {
      return res
        .status(404)
        .send({ success: false, message: "Class not found" });
    }

    return res
      .status(200)
      .send({ success: true, isStreaming: result[0][0].isStreaming == 1 });
  } catch (error) {
    console.error(error?.message);
    return res
      .status(500)
      .send({ success: false, message: "Internal Server Error" });
  }
});

module.exports = client;
