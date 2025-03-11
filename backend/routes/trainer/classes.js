const express = require("express");
const multer = require("multer");
const ImageKit = require("imagekit");
const { authorize } = require("../../middlewares/authorize");

const trainerClasses = express.Router();

var imagekit = new ImageKit({
  publicKey: process.env.IMAGEKIT_PUBLIC_KEY,
  privateKey: process.env.IMAGEKIT_PRIVATE_KEY,
  urlEndpoint: process.env.IMAGEKIT_URL_ENDPOINT,
});

const storage = multer.memoryStorage();
const upload = multer({ storage }).single("image");

trainerClasses.post("/create", authorize, upload, async (req, res) => {
  const db = req.db;
  const userData = req.userData;
  let imageId;
  let imageName;

  try {
    if (req?.file) {
      const response = await imagekit.upload({
        file: req.file.buffer,
        fileName: Math.round(Math.random() * 1e12).toString(),
        folder: "trainerClassImages",
        useUniqueFileName: false,
      });

      imageId = response.fileId;
      imageName = response.name;
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
        imageId,
        imageName
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
      imageId || null,
      imageName || null,
    ];

    const result = await db.query(query, values);

    const query2 = `
      SELECT 
        TrainerClasses.*, 
        (TrainerClasses.maxParticipants - 
          (SELECT COUNT(*) 
           FROM registeredclasses 
           WHERE registeredclasses.classId = TrainerClasses.id)
        ) AS remainingSeats
      FROM TrainerClasses
      WHERE trainerId = ? AND id = ?;
    `;

    const classes = await db.query(query2, [
      userData.id,
      result[0]["insertId"],
    ]);

    var data = classes[0][0];
    data.imageData = { id: data.imageId, name: data.imageName };
    delete data.imageId;
    delete data.imageName;

    res.status(200).send({
      message: "Class created successfully",
      data,
    });
  } catch (error) {
    if (imageId) {
      try {
        await imagekit.deleteFile(imageId);
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

trainerClasses.get("/", authorize, async (req, res) => {
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
    var data = classes[0];
    data.forEach((obj) => {
      obj.imageData = { id: obj.imageId, name: obj.imageName };
      delete obj.imageId;
      delete obj.imageName;
    });
    return res.status(200).send({ success: true, data });
  } catch (error) {
    console.error(error?.message);
    return res
      .status(500)
      .send({ success: false, message: "Internal Server Error" });
  }
});

trainerClasses.delete("/delete/:classId", authorize, async (req, res) => {
  const db = req.db;
  const { classId } = req.params;

  if (!classId) {
    return res
      .status(400)
      .send({ success: false, message: "classId is required" });
  }

  try {
    await db.beginTransaction();

    const checkQuery = `SELECT imageId FROM TrainerClasses WHERE id = ? AND trainerId = ?;`;
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

    const imageId = checkResult[0].imageId ? checkResult[0].imageId : null;

    const deleteQuery = `DELETE FROM TrainerClasses WHERE id = ?;`;
    const [deleteResult] = await db.query(deleteQuery, [classId]);

    if (deleteResult.affectedRows === 0) {
      await db.rollback();
      return res
        .status(500)
        .send({ success: false, message: "Failed to delete class" });
    }

    if (imageId) {
      try {
        await imagekit.deleteFile(imageId);
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

trainerClasses.put("/update-streaming", authorize, async (req, res) => {
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

module.exports = trainerClasses;
