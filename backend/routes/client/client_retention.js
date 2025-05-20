const express = require("express");
const axios = require("axios");
const { authorize } = require("../../middlewares/authorize");

const clientRetention = express.Router();

clientRetention.post("/update-data", authorize, async (req, res) => {
  const db = req.db;
  try {
    const userId = req.userData.id;

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

    const [classes] = await db.execute(
      `SELECT
         TrainerClasses.*,
         gyms.gymName,
         gyms.gymLocation,
         gyms.id AS gymId
       FROM TrainerClasses
       JOIN registeredclasses
         ON TrainerClasses.id = registeredclasses.classId
       JOIN gyms
         ON TrainerClasses.gymId = gyms.id
       WHERE registeredclasses.clientId = ?`,
      [userId]
    );

    const data = {};

    for (let classInfo of classes) {
      const {
        gymId,
        id: classId,
        gymName,
        startDate,
        endDate,
        selectedDays,
      } = classInfo;

      const key = `${gymId}_${classId}`;
      if (!req.body[key]) continue;

      const start = new Date(startDate);
      const end = new Date(endDate);
      const now = new Date();

      const contract_period = Math.round(
        (end.getFullYear() - start.getFullYear()) * 12 +
          (end.getMonth() - start.getMonth())
      );

      const month_to_end_contract = Math.max(
        0,
        Math.round(
          (end.getFullYear() - now.getFullYear()) * 12 +
            (end.getMonth() - now.getMonth())
        )
      );

      const weeklyFrequency = JSON.parse(selectedDays).filter(Boolean).length;
      const totalWeeks = Math.floor((end - start) / (1000 * 60 * 60 * 24 * 7));
      const avg_class_frequency_total = +(weeklyFrequency * totalWeeks).toFixed(
        2
      );

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
        Near_Location: req.body[key].nearLocation,
        Partner: req.body[key].partner,
        Phone: phone,
        Contract_period: contract_period,
        Age,
        Month_to_end_contract: month_to_end_contract,
        Avg_class_frequency_total: avg_class_frequency_total,
        Avg_class_frequency_current_month: avg_class_frequency_current_month,
      };

      data[key] = payload;
    }

    const pythonResponse = await axios.post(
      "http://127.0.0.1:5000/predict",
      data
    );
    const predictions = pythonResponse.data.predictions;

    for (const key in predictions) {
      const [gymId, classId] = key.split("_").map(Number);
      const {
        gender,
        Near_Location,
        Partner,
        Phone,
        Contract_period,
        Age,
        Month_to_end_contract,
        Avg_class_frequency_total,
        Avg_class_frequency_current_month,
        churn,
      } = predictions[key];

      await db.execute(
        `INSERT INTO clientretention (
      userId, gymId, classId, gender, nearLocation, partner, phone,
      contractPeriod, age, monthToEndContract,
      avgClassFrequencyTotal, avgClassFrequencyCurrentMonth, churn
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          userId,
          gymId,
          classId,
          gender,
          Near_Location,
          Partner,
          Phone,
          Contract_period,
          Age,
          Month_to_end_contract,
          Avg_class_frequency_total,
          Avg_class_frequency_current_month,
          churn,
        ]
      );
    }

    res.status(200).json({ success: true });
  } catch (err) {
    console.log(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

module.exports = clientRetention;
