const express = require("express");
const bcrypt = require("bcrypt");
const { createToken } = require("../../utils/token");

const signin = express.Router();

function validate(Email, Password) {
  // if (!phone.match(/^\+?\d{8,15}$/)) {
  //   return "Invalid Phone Number";
  // }
  if (!/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(Email)) {
    return "Invalid Email";
  } else if (!Password.match(/^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,20}$/)) {
    return "Incorrect Password";
  } else {
    return undefined;
  }
}

signin.post("/", async (req, res) => {
  const db = req.db;
  try {
    if (req.body.email && req.body.password) {
      var loginData = {
        email: req.body.email.trim(),
        password: req.body.password,
      };
    } else {
      return res
        .status(403)
        .send({ message: "Incomplete info entered", isLoggedIn: false });
    }

    const error = validate(loginData.email, loginData.password);
    if (error) {
      return res.status(403).send({ message: error, isLoggedIn: false });
    }

    const [foundUser] = await db.query(
      "SELECT * FROM gym_pos_system.Users WHERE email = ?",
      [loginData.email]
    );

    if (foundUser.length === 0) {
      return res
        .status(401)
        .send({ message: "No account registered with this email" });
    }

    const validPassword = await bcrypt.compare(
      loginData.password,
      foundUser[0].password
    );
    if (!validPassword) {
      return res
        .status(401)
        .send({ message: "Incorrect Password", isLoggedIn: false });
    }

    var userData = { ...foundUser[0] };
    delete userData.password;
    delete userData.id;

    var tokenExpirationTime =
      Date.now() + 1000 * 60 * 60 * 24 * 365 - 1000 * 30;
    const authToken = createToken(foundUser[0].id, "365d");

    res.status(200).send({
      message: "Signed In successfully!",
      isLoggedIn: true,
      authToken,
      tokenExpirationTime,
      data: userData,
    });
  } catch (err) {
    console.error("Error during login: ", err);
    return res.status(500).send({ message: "Internal server error" });
  }
});

module.exports = signin;
