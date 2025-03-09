const express = require("express");
const multer = require("multer");
const { authorize } = require("../../middlewares/authorize");
const ImageKit = require("imagekit");

const owner = express.Router();

var imagekit = new ImageKit({
  publicKey: process.env.IMAGEKIT_PUBLIC_KEY,
  privateKey: process.env.IMAGEKIT_PRIVATE_KEY,
  urlEndpoint: process.env.IMAGEKIT_URL_ENDPOINT,
});

const storage = multer.memoryStorage();
const upload = multer({ storage }).single("image");

owner.get("/", authorize, async (req, res) => {
  const db = req.db;
  const userData = req.userData;

  try {
    const query = `SELECT * FROM posProducts WHERE userId = ?;`;
    const result = await db.query(query, [userData.userId]);
    res.status(200).send({ success: true, data: result[0] });
  } catch (err) {
    console.log(err?.message);
    res.status(500).send({ success: false, message: "Internal Server Error" });
  }
});

owner.post("/create-product", authorize, async (req, res) => {
  const db = req.db;
  const userData = req.userData;

  console.log(req.body);

  res.send("Owner POS");
});

module.exports = owner;
