const express = require("express");
const multer = require("multer");
const { authorize } = require("../../middlewares/authorize");
const ImageKit = require("imagekit");

const ownerPOSProducts = express.Router();

var imagekit = new ImageKit({
  publicKey: process.env.IMAGEKIT_PUBLIC_KEY,
  privateKey: process.env.IMAGEKIT_PRIVATE_KEY,
  urlEndpoint: process.env.IMAGEKIT_URL_ENDPOINT,
});

const storage = multer.memoryStorage();
const upload = multer({ storage }).single("image");

ownerPOSProducts.get("/", authorize, async (req, res) => {
  const db = req.db;
  const userData = req.userData;

  try {
    const query = `SELECT * FROM posProducts WHERE creatorId = ?;`;
    const result = await db.query(query, [userData.id]);
    var data = result[0];
    data.forEach((obj) => {
      obj.imageData = { id: obj.imageId, name: obj.imageName };
      delete obj.imageId;
      delete obj.imageName;
    });

    res.status(200).send({ success: true, data });
  } catch (err) {
    console.log(err?.message);
    res.status(500).send({ success: false, message: "Internal Server Error" });
  }
});

ownerPOSProducts.post(
  "/create-product",
  authorize,
  upload,
  async (req, res) => {
    const db = req.db;
    const userData = req.userData;

    let imageId;
    let imageName;

    try {
      if (req?.file) {
        const response = await imagekit.upload({
          file: req.file.buffer,
          fileName: Math.round(Math.random() * 1e12).toString(),
          folder: "posProductImages",
          useUniqueFileName: false,
        });

        imageId = response.fileId;
        imageName = response.name;
      }

      const { productName, location, quantity, description, price, condition } =
        req.body;

      const query = `
      INSERT INTO POSProducts (
        creatorId,
        productName,
        location,
        quantity,
        description,
        price,
        \`condition\`,
        imageId,
        imageName
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

      const values = [
        userData.id,
        productName.trim(),
        location.trim(),
        quantity.trim(),
        description.trim(),
        price.trim(),
        condition.trim(),
        imageId || null,
        imageName || null,
      ];

      const result = await db.query(query, values);

      res.status(200).send({
        message: "Product created successfully",
        data: {
          id: result[0]["insertId"],
          productName: productName.trim(),
          location: location.trim(),
          quantity: quantity.trim(),
          description: description.trim(),
          price: price.trim(),
          condition: condition.trim(),
          imageData: { id: imageId, name: imageName } || null,
        },
      });
    } catch (error) {
      if (imageId) {
        try {
          await imagekit.deleteFile(imageId);
        } catch (deleteError) {
          console.log(
            "Error deleting image from ImageKit:",
            deleteError.message
          );
        }
      }

      console.log(error?.message);
      return res.status(500).send({
        message: "An error occurred while creating the product.",
      });
    }
  }
);

ownerPOSProducts.delete("/delete/:productId", authorize, async (req, res) => {
  const db = req.db;
  const { productId } = req.params;

  if (!productId) {
    return res
      .status(400)
      .send({ success: false, message: "productId is required" });
  }

  try {
    await db.beginTransaction();

    const checkQuery = `SELECT imageId FROM POSProducts WHERE id = ? AND creatorId = ?;`;
    const [checkResult] = await db.query(checkQuery, [
      productId,
      req.userData.id,
    ]);

    if (checkResult.length === 0) {
      await db.rollback();
      return res
        .status(404)
        .send({ success: false, message: "Product not found or unauthorized" });
    }

    const imageId = checkResult[0].imageId ? checkResult[0].imageId : null;

    const deleteQuery = `DELETE FROM POSProducts WHERE id = ?;`;
    const [deleteResult] = await db.query(deleteQuery, [productId]);

    if (deleteResult.affectedRows === 0) {
      await db.rollback();
      return res
        .status(500)
        .send({ success: false, message: "Failed to delete product" });
    }

    if (imageId) {
      try {
        await imagekit.deleteFile(imageId);
      } catch (deleteError) {
        await db.rollback();
        console.log("Error deleting image from ImageKit:", deleteError.message);
        return res
          .status(500)
          .send({ success: false, message: "Failed to delete product image" });
      }
    }

    await db.commit();
    return res
      .status(200)
      .send({ success: true, message: "Product deleted successfully" });
  } catch (error) {
    await db.rollback();
    console.error(error?.message);
    return res
      .status(500)
      .send({ success: false, message: "Internal Server Error" });
  }
});

module.exports = ownerPOSProducts;
