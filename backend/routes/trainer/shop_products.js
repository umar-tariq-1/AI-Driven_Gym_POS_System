const express = require("express");
const { authorize } = require("../../middlewares/authorize");

const shopProducts = express.Router();

shopProducts.get("/", authorize, async (req, res) => {
  const db = req.db;

  try {
    const query = `
    SELECT posProducts.*, 
          CONCAT(users.firstName, ' ', users.lastName) AS sellerName
    FROM posProducts
    JOIN users ON posProducts.creatorId = users.id;
    `;
    const result = await db.query(query);
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

shopProducts.post("/purchase", authorize, async (req, res) => {
  const db = req.db;

  try {
    const { productId, requiredQuantity } = req.body;

    const checkQuery = `SELECT quantity FROM posProducts WHERE id = ?;`;
    const checkResult = await db.query(checkQuery, [productId]);

    if (checkResult[0].length === 0) {
      return res
        .status(404)
        .send({ success: false, message: "Product not found" });
    }

    const availableQuantity = checkResult[0][0].quantity;

    if (requiredQuantity > availableQuantity) {
      return res
        .status(400)
        .send({ success: false, message: "Insufficient stock" });
    }

    const updateQuery = `UPDATE posProducts SET quantity = quantity - ? WHERE id = ?;`;
    await db.query(updateQuery, [requiredQuantity, productId]);

    return res
      .status(200)
      .send({ success: true, message: "Purchase successful" });
  } catch (error) {
    console.error(error?.message);
    return res
      .status(500)
      .send({ success: false, message: "Internal Server Error" });
  }
});

module.exports = shopProducts;
