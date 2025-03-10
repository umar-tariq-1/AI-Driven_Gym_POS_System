const express = require("express");
const cors = require("cors");
const { connectDatabase } = require("./database/connection");
require("dotenv").config();

const register = require("./routes/User/register");
const signin = require("./routes/User/signin");
const deleteUser = require("./routes/User/delete");
const editUser = require("./routes/User/edit");
const OTP = require("./routes/User/otp");
const trainerClasses = require("./routes/trainer/classes");
const clientClasses = require("./routes/client/classes");
const ownerPOSProducts = require("./routes/owner/pos");
const clientShopProducts = require("./routes/client/shop_products");
const trainerShopProducts = require("./routes/trainer/shop_products");

const app = express();

app.use(
  cors({
    origin: process.env.ORIGIN || "*",
    credentials: true,
    allowedHeaders: ["Content-Type", "Authorization"],
  })
);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

(async () => {
  try {
    const db = await connectDatabase();

    app.use((req, res, next) => {
      req.db = db;
      next();
    });

    // User routes
    app.use("/register", register);
    app.use("/signin", signin);
    app.use("/delete-user", deleteUser);
    app.use("/edit-user", editUser);
    app.use("/otp", OTP);

    // Trainer routes
    app.use("/trainer/classes", trainerClasses);
    app.use("/trainer/shop-products", trainerShopProducts);

    // Client routes
    app.use("/client/classes", clientClasses);
    app.use("/client/shop-products", clientShopProducts);

    //Owner routes
    app.use("/owner/pos", ownerPOSProducts);

    const PORT = process.env.PORT || 3001;
    app.listen(PORT, () => {
      console.log(`Server Listening to Port ${PORT}...`);
    });
  } catch (error) {
    console.error(
      "Failed to start the server due to database connection error:",
      error
    );
  }
})();
