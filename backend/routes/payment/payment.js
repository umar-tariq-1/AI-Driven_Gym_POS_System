const express = require("express");
const { authorize } = require("../../middlewares/authorize");

const payment = express.Router();

payment.post("/", authorize, async (req, res) => {
  const db = req.db;
  const userData = req.userData;

  try {
    const userId = userData.id;

    return res.status(200).send({ success: true });
  } catch (error) {
    console.error(error?.message);
    return res
      .status(500)
      .send({ success: false, message: "Internal Server Error" });
  }
});

module.exports = payment;
