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
        classType,
        fitnessLevel,
        classGender,
        classCategory,
        selectedDays,
        startTime,
        endTime,
        startDate,
        endDate,
        trainerId,
        imageData
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

    const values = [
      className.trim(),
      gymName.trim(),
      gymLocation.trim(),
      trainerName.trim(),
      classDescription.trim(),
      maxParticipants.trim(),
      classFee.trim(),
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
        id: result[0]["insertId"],
        className,
        gymName,
        gymLocation,
        trainerName,
        classDescription,
        maxParticipants: parseInt(maxParticipants),
        remainingSeats: parseInt(maxParticipants),
        classFee,
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
        trainerId: userData.id,
        isStreaming: 0,
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
      SELECT 
        TrainerClasses.*, 
        (TrainerClasses.maxParticipants - 
          (SELECT COUNT(*) 
           FROM registeredclasses 
           WHERE registeredclasses.classId = TrainerClasses.id)
        ) AS remainingSeats
      FROM TrainerClasses
      WHERE trainerId = ?;
    `;
    const classes = await db.query(query, [userData.id]);

    return res.status(200).send({ success: true, data: classes[0] });
  } catch (error) {
    console.error(error?.message);
    return res
      .status(500)
      .send({ success: false, message: "Internal Server Error" });
  }
});

trainer.delete("/delete/:classId", authorize, async (req, res) => {
  const db = req.db;
  const { classId } = req.params;

  if (!classId) {
    return res
      .status(400)
      .send({ success: false, message: "classId is required" });
  }

  try {
    await db.beginTransaction();

    const checkQuery = `SELECT imageData FROM TrainerClasses WHERE id = ? AND trainerId = ?;`;
    const [checkResult] = await db.query(checkQuery, [
      classId,
      req.userData.id,
    ]);

    if (checkResult.length === 0) {
      await db.rollback();
      return res
        .status(404)
        .send({ success: false, message: "Class not found or unauthorized" });
    }

    const imageData = checkResult[0].imageData
      ? checkResult[0].imageData
      : null;

    const deleteQuery = `DELETE FROM TrainerClasses WHERE id = ?;`;
    const [deleteResult] = await db.query(deleteQuery, [classId]);

    if (deleteResult.affectedRows === 0) {
      await db.rollback();
      return res
        .status(500)
        .send({ success: false, message: "Failed to delete class" });
    }

    if (imageData?.id) {
      try {
        await imagekit.deleteFile(imageData.id);
      } catch (deleteError) {
        await db.rollback();
        console.log("Error deleting image from ImageKit:", deleteError.message);
        return res
          .status(500)
          .send({ success: false, message: "Failed to delete class image" });
      }
    }

    await db.commit();
    return res
      .status(200)
      .send({ success: true, message: "Class deleted successfully" });
  } catch (error) {
    await db.rollback();
    console.error(error?.message);
    return res
      .status(500)
      .send({ success: false, message: "Internal Server Error" });
  }
});

trainer.put("/update-streaming", authorize, async (req, res) => {
  const db = req.db;
  const { classId, isStreaming } = req.body;

  if (classId === undefined || isStreaming === undefined) {
    return res.status(400).send({
      success: false,
      message: "classId and isStreaming are required",
    });
  }

  try {
    const query = `
      UPDATE TrainerClasses 
      SET isStreaming = ? 
      WHERE id = ?;
    `;
    const result = await db.query(query, [isStreaming, classId]);

    if (result[0].affectedRows === 0) {
      return res
        .status(404)
        .send({ success: false, message: "Class not found" });
    }

    return res.status(200).send({
      success: true,
      message: "Streaming status updated successfully",
    });
  } catch (error) {
    console.log(error?.message);
    return res
      .status(500)
      .send({ success: false, message: "Internal Server Error" });
  }
});

module.exports = trainer;
