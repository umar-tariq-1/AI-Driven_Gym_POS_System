const express = require("express");
const { authorize } = require("../../middlewares/authorize");

const client = express.Router();

client.get("/", async (req, res) => {
  const db = req.db;
  const userData = req.userData;

  try {
    const query = `
  SELECT TrainerClasses.*, 
         JSON_OBJECT(
           'firstName', Users.firstName,
           'lastName', Users.lastName
         ) AS trainer
  FROM TrainerClasses
  JOIN gym_pos_system.users AS Users
  ON TrainerClasses.userId = Users.id;
`;
    const classes = await db.query(query);

    return res.status(200).send({ success: true, data: classes[0] });
  } catch (error) {
    console.error(error?.message);
    return res.status(500).send({ success: false, message: error?.message });
  }
});

module.exports = client;
