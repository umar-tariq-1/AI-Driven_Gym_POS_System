const express = require("express");
const { authorize } = require("../../middlewares/authorize");

const client = express.Router();

client.get("/classes", authorize, async (req, res) => {
  const db = req.db;
  const userData = req.userData;

  try {
    const query = `
      SELECT * FROM TrainerClasses;
    `;
    const classes = await db.query(query);

    return res.status(200).send({ success: true, data: classes });
  } catch (error) {
    console.error(error?.message);
    return res.status(500).send({ success: false, message: error?.message });
  }
});

module.exports = client;
