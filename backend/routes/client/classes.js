const express = require("express");
const { authorize } = require("../../middlewares/authorize");
const dayjs = require("dayjs");
const isSameOrBefore = require("dayjs/plugin/isSameOrBefore");
dayjs.extend(isSameOrBefore);

const clientClasses = express.Router();

clientClasses.get("/", authorize, async (req, res) => {
  const db = req.db;
  const userData = req.userData;

  try {
    const userId = userData.id;

    const query = `
      SELECT 
        TrainerClasses.*, 
        gyms.gymName,
        gyms.gymLocation,
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
        ON TrainerClasses.trainerId = Users.id
      JOIN gyms
        ON TrainerClasses.gymId = gyms.id;
    `;

    const classes = await db.query(query, [userId]);
    var data = classes[0];
    data.forEach((obj) => {
      obj.imageData = { id: obj.imageId, name: obj.imageName };
      delete obj.imageId;
      delete obj.imageName;
    });

    return res.status(200).send({ success: true, data });
  } catch (error) {
    console.error(error?.message);
    return res
      .status(500)
      .send({ success: false, message: "Internal Server Error" });
  }
});

clientClasses.post("/register", authorize, async (req, res) => {
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

clientClasses.get("/registered-classes", authorize, async (req, res) => {
  const db = req.db;
  const userData = req.userData;

  try {
    const userId = userData.id;

    const query = `
      SELECT
        TrainerClasses.*,
        gyms.gymName,
        gyms.gymLocation
      FROM TrainerClasses
      JOIN registeredclasses
        ON TrainerClasses.id = registeredclasses.classId
      JOIN gyms
        ON TrainerClasses.gymId = gyms.id
      WHERE registeredclasses.clientId = ?;
    `;

    const classes = await db.query(query, [userId]);
    var data = classes[0];
    data.forEach((obj) => {
      obj.imageData = { id: obj.imageId, name: obj.imageName };
      delete obj.imageId;
      delete obj.imageName;
    });

    return res.status(200).send({ success: true, data });
  } catch (error) {
    console.error(error?.message);
    return res
      .status(500)
      .send({ success: false, message: "Internal Server Error" });
  }
});

clientClasses.get("/home", authorize, async (req, res) => {
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
    let data = classes[0];

    const today = dayjs();
    let totalHeldClasses = 0;

    data = data.map((obj) => {
      obj.imageData = { id: obj.imageId, name: obj.imageName };
      delete obj.imageId;
      delete obj.imageName;

      const selectedDays = JSON.parse(obj.selectedDays);
      const startDate = dayjs(obj.startDate);
      const endDate = dayjs(obj.endDate);

      let total = 0,
        held = 0;

      for (let d = startDate; d.isSameOrBefore(endDate); d = d.add(1, "day")) {
        const dayIndex = (d.day() + 6) % 7;
        if (selectedDays[dayIndex]) {
          total++;
          if (d.isBefore(today, "day")) held++;
        }
      }

      obj.totalClasses = total;
      obj.heldClasses = held;
      totalHeldClasses += held;

      return obj;
    });

    const attendanceQuery = `
      SELECT status, COUNT(*) AS count
      FROM Attendance
      WHERE clientId = ?
      GROUP BY status;
    `;
    const attendanceResult = await db.query(attendanceQuery, [userId]);
    let totalPresent = 0,
      totalLate = 0;

    attendanceResult[0].forEach((row) => {
      if (row.status === "present") totalPresent = row.count;
      if (row.status === "late") totalLate = row.count;
    });

    return res.status(200).send({
      success: true,
      data,
      totalHeldClasses,
      totalPresent,
      totalLate,
    });
  } catch (error) {
    console.error(error?.message);
    return res
      .status(500)
      .send({ success: false, message: "Internal Server Error" });
  }
});

clientClasses.get("/is-streaming/:classId", authorize, async (req, res) => {
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

clientClasses.post("/attendance", authorize, async (req, res) => {
  const db = req.db;
  const { classId } = req.body;
  const clientId = req.userData.id;

  if (!classId) {
    return res.status(400).send({
      success: false,
      message: "classId is required",
    });
  }

  try {
    const [result] = await db.query(
      `SELECT startTime FROM TrainerClasses WHERE id = ?`,
      [classId]
    );

    if (result.length === 0) {
      return res.status(404).send({
        success: false,
        message: "Class not found",
      });
    }

    const startingTimeStr = result[0].startTime;
    const now = new Date();
    const [h, m, s] = startingTimeStr.split(":").map(Number);
    const classStartTime = new Date(now);
    classStartTime.setHours(h, m, s, 0);

    const diffInMinutes = (now - classStartTime) / (1000 * 60);
    const finalStatus = diffInMinutes > 5 ? "late" : "present";

    await db.query(
      `
      INSERT INTO attendance (classId, clientId, status)
      VALUES (?, ?, ?)
      ON DUPLICATE KEY UPDATE status = VALUES(status);
    `,
      [classId, clientId, finalStatus]
    );

    return res.status(200).send({
      success: true,
      message: `Attendance marked as '${finalStatus}'`,
    });
  } catch (error) {
    console.log(error?.message);
    return res.status(500).send({
      success: false,
      message: "Internal Server Error",
    });
  }
});

module.exports = clientClasses;
