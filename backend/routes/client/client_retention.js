const express = require("express");
const axios = require("axios");
const { authorize } = require("../../middlewares/authorize");

const clientRetention = express.Router();

clientRetention.post("/update-data", authorize, async (req, res) => {
  const db = req.db;
  console.log(req.body);
  try {
    const userId = req.userData.id;
    const { nearLocation, partner } = req.body;

    // 1. Get gender, age & phone from users table
    const [userResult] = await db.execute(
      "SELECT gender, phone, dob FROM users WHERE id = ?",
      [userId]
    );
    const gender = userResult[0]?.gender || 0;
    const phone = userResult[0]?.phone ? 1 : 0;
    const dob = userResult[0]?.dob;
    const ageDifMs = Date.now() - dob.getTime();
    const ageDate = new Date(ageDifMs);
    const Age = Math.abs(ageDate.getUTCFullYear() - 1970);

    // 2. Get all classes of this client
    const [classes] = await db.execute(
      `SELECT
        *
      FROM TrainerClasses
      JOIN registeredclasses
        ON TrainerClasses.id = registeredclasses.classId
      WHERE registeredclasses.clientId = ?`,
      [userId]
    );

    const results = [];

    for (let classInfo of classes) {
      const { gymName, startDate, endDate, selectedDays } = classInfo;

      const start = new Date(startDate);
      const end = new Date(endDate);
      const now = new Date();

      // Contract period in months
      const contract_period = Math.round(
        (end.getFullYear() - start.getFullYear()) * 12 +
          (end.getMonth() - start.getMonth())
      );

      // Months to end contract
      const month_to_end_contract = Math.max(
        0,
        Math.round(
          (end.getFullYear() - now.getFullYear()) * 12 +
            (end.getMonth() - now.getMonth())
        )
      );

      // Calculate total class days per week from JSON schedule
      const weeklyFrequency = JSON.parse(selectedDays).filter(Boolean).length;

      // Avg total frequency = (weeks in full contract) * days per week
      const totalWeeks = Math.floor((end - start) / (1000 * 60 * 60 * 24 * 7));
      const avg_class_frequency_total = +(weeklyFrequency * totalWeeks).toFixed(
        2
      );

      // Avg frequency current month
      const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
      const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0);
      const daysInMonth =
        (endOfMonth - startOfMonth) / (1000 * 60 * 60 * 24) + 1;

      const weeksInMonth = daysInMonth / 7;
      const avg_class_frequency_current_month = +(
        weeklyFrequency * weeksInMonth
      ).toFixed(2);

      const payload = {
        gender: gender == "Male" ? 1 : 0,
        Near_Location: nearLocation,
        Partner: partner,
        Phone: phone,
        Contract_period: contract_period,
        Age,
        Month_to_end_contract: month_to_end_contract,
        Avg_class_frequency_total: avg_class_frequency_total,
        Avg_class_frequency_current_month: avg_class_frequency_current_month,
      };
      console.log("\n\nPayload for prediction:", payload);
      const pythonResponse = await axios.post(
        "http://localhost:5000/predict",
        payload
      );
      console.log("\n\nPython response:", pythonResponse.data);
      const churn = pythonResponse.data.churn;

      // Save to DB
      await db.execute(
        `INSERT INTO gym_churn_predictions 
        (userId, gymName, gender, nearLocation, partner, phone, contractPeriod, age, monthToEndContract, avgClassFrequencyTotal, avgClassFrequencyCurrent_month, churnResult)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          userId,
          gymName,
          gender,
          Near_Location,
          Partner,
          phone,
          contract_period,
          Age,
          month_to_end_contract,
          avg_class_frequency_total,
          avg_class_frequency_current_month,
          churn,
        ]
      );

      results.push({ gym: gymName, churn });
    }

    res.status(200).json({ success: true, data: results });
  } catch (err) {
    console.log(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

module.exports = clientRetention;
