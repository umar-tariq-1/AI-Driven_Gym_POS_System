const express = require("express");
const axios = require("axios");
const { authorize } = require("../../middlewares/authorize");

const clientRetention = express.Router();

clientRetention.get("/", authorize, async (req, res) => {
  const db = req.db;
  try {
    const userId = req.userData.id;

    const [results] = await db.execute(
      `
        SELECT 
          g.id AS gymId,
          g.gymName,
          tc.id AS classId,
          tc.className,
          tc.classFee AS classFee,
          COUNT(DISTINCT rc.clientId) AS totalStudents,
          cr.churn,
          COUNT(cr.id) AS churnCount
        FROM gyms g
        LEFT JOIN trainerclasses tc ON tc.gymId = g.id
        LEFT JOIN registeredclasses rc ON rc.classId = tc.id
        LEFT JOIN clientretention cr ON cr.classId = tc.id AND cr.gymId = g.id
        WHERE g.ownerId = ?
        GROUP BY g.id, tc.id, cr.churn
        `,
      [userId]
    );

    let totalGyms = new Set();
    let totalClasses = new Set();
    let totalClients = new Set();
    let totalRevenue = 0;
    let churnStats = {};

    const studentMap = {};

    for (let row of results) {
      const {
        gymId,
        gymName,
        classId,
        className,
        classFee,
        churn,
        churnCount,
      } = row;

      if (!classId) continue;

      totalGyms.add(gymId);
      totalClasses.add(classId);

      if (!studentMap[classId]) studentMap[classId] = new Set();
      if (row.totalStudents) {
        studentMap[classId].add(row.totalStudents);
        totalClients.add(`${gymId}_${classId}`);
      }

      totalRevenue += (classFee || 0) * (row.totalStudents || 0);

      if (!churnStats[gymId])
        churnStats[gymId] = {
          gymName,
          classes: {},
        };

      if (!churnStats[gymId].classes[classId]) {
        churnStats[gymId].classes[classId] = {
          className,
          churn0: 0,
          churn1: 0,
        };
      }

      if (churn === 0) churnStats[gymId].classes[classId].churn0 += churnCount;
      else if (churn === 1)
        churnStats[gymId].classes[classId].churn1 += churnCount;
    }

    res.status(200).json({
      success: true,
      totalGyms: totalGyms.size,
      totalClasses: totalClasses.size,
      totalClients: totalClients.size,
      totalRevenue,
      churnStats,
    });
  } catch (err) {
    console.log(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

module.exports = clientRetention;
