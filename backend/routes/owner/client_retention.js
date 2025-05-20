const express = require("express");
const axios = require("axios");
const { authorize } = require("../../middlewares/authorize");

const clientRetention = express.Router();

clientRetention.get("/", authorize, async (req, res) => {
  const db = req.db;
  try {
    const ownerId = req.userData.id;

    // Get gyms with their classes for this owner
    const [gymsWithClasses] = await db.execute(
      `SELECT g.id AS gymId, g.gymName, c.id AS classId, c.classFee
         FROM gyms g
         JOIN TrainerClasses c ON g.id = c.gymId
         WHERE g.ownerId = ?`,
      [ownerId]
    );

    // Get student counts for all classes
    const [studentCounts] = await db.execute(
      `SELECT classId, COUNT(*) AS totalStudents
         FROM registeredClasses
         GROUP BY classId`
    );

    // Get churn results for all classes
    const [churnCounts] = await db.execute(
      `SELECT classId, churn, COUNT(*) AS count
         FROM clientRetention
         GROUP BY classId, churn`
    );

    // Create lookup maps
    const studentCountMap = {};
    studentCounts.forEach((row) => {
      studentCountMap[row.classId] = row.totalStudents;
    });

    const churnMap = {};
    churnCounts.forEach((row) => {
      if (!churnMap[row.classId])
        churnMap[row.classId] = { churn0: 0, churn1: 0 };
      if (row.churn === 0) churnMap[row.classId].churn0 = row.count;
      if (row.churn === 1) churnMap[row.classId].churn1 = row.count;
    });

    // Build response
    const gymMap = {};
    gymsWithClasses.forEach((row) => {
      if (!gymMap[row.gymId]) {
        gymMap[row.gymId] = {
          gymId: row.gymId,
          gymName: row.gymName,
          classesData: [],
        };
      }

      gymMap[row.gymId].classesData.push({
        classId: row.classId,
        classFee: row.classFee,
        totalStudents: studentCountMap[row.classId] || 0,
        churn0: churnMap[row.classId]?.churn0 || 0,
        churn1: churnMap[row.classId]?.churn1 || 0,
      });
    });

    res.status(200).json({
      success: true,
      gymData: Object.values(gymMap),
    });
  } catch (err) {
    console.log(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

module.exports = clientRetention;
