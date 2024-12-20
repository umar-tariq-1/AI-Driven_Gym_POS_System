const express = require("express");
const multer = require("multer");
const ImageKit = require("imagekit");
const { authorize } = require("../../middlewares/authorize");

const trainer = express.Router();

var imagekit = new ImageKit({
  publicKey: process.env.IMAGEKIT_PUBLIC_KEY,
  privateKey: process.env.IMAGEKIT_PRIVATE_KEY,
  urlEndpoint: process.env.IMAGEKIT_URL_ENDPOINT,
});

const storage = multer.memoryStorage();
const upload = multer({ storage }).single("image");

trainer.post("/create", authorize, upload, async (req, res) => {
  const db = req.db;
  const userData = req.userData;
  let image;

  try {
    if (req?.file) {
      const response = await imagekit.upload({
        file: req.file.buffer,
        fileName: Math.round(Math.random() * 1e9).toString(),
        folder: "trainerClassImages",
        useUniqueFileName: false,
      });

      image = { name: response.name, id: response.fileId };
    }

    const {
      className,
      gymName,
      gymLocation,
      trainerName,
      classDescription,
      maxParticipants,
      classFee,
      specialRequirements,
      classType,
      fitnessLevel,
      classGender,
      classCategory,
      selectedDays,
      startTime,
      endTime,
      startDate,
      endDate,
    } = req.body;

    const query = `
      INSERT INTO TrainerClasses (
        className,
        gymName,
        gymLocation,
        trainerName,
        classDescription,
        maxParticipants,
        classFee,
        specialRequirements,
        classType,
        fitnessLevel,
        classGender,
        classCategory,
        selectedDays,
        startTime,
        endTime,
        startDate,
        endDate,
        userId,
        imageData
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

    const values = [
      className.trim(),
      gymName.trim(),
      gymLocation.trim(),
      trainerName.trim(),
      classDescription.trim(),
      maxParticipants.trim(),
      classFee.trim(),
      specialRequirements.trim(),
      classType?.trim(),
      fitnessLevel?.trim(),
      classGender?.trim(),
      classCategory?.trim(),
      JSON.stringify(selectedDays),
      startTime?.trim(),
      endTime?.trim(),
      startDate?.trim(),
      endDate?.trim(),
      userData.id,
      image ? JSON.stringify(image) : null,
    ];

    const result = await db.query(query, values);

    res.status(200).send({
      message: "Class created successfully",
      data: {
        className,
        gymName,
        gymLocation,
        trainerName,
        classDescription,
        maxParticipants,
        classFee,
        specialRequirements,
        classType,
        fitnessLevel,
        classGender,
        classCategory,
        selectedDays,
        startTime,
        endTime,
        startDate,
        endDate,
        imageData: image || null,
      },
    });
  } catch (error) {
    if (image) {
      try {
        await imagekit.deleteFile(image.id);
      } catch (deleteError) {
        console.log("Error deleting image from ImageKit:", deleteError.message);
      }
    }

    console.log(error?.message);
    return res.status(500).send({
      message: "An error occurred while creating the class.",
    });
  }
});

trainer.get("/", authorize, async (req, res) => {
  const db = req.db;
  const userData = req.userData;

  try {
    const query = `
      SELECT * FROM TrainerClasses WHERE userId = ?;
    `;
    const classes = await db.query(query, [userData.id]);

    return res.status(200).send({ success: true, data: classes[0] });
  } catch (error) {
    console.error(error?.message);
    return res.status(500).send({ success: false, message: error?.message });
  }
});

module.exports = trainer;
