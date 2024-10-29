require("dotenv").config();
const jwt = require("jsonwebtoken");

module.exports.createToken = (id, expiresIn = "24h") => {
  return jwt.sign({ id }, process.env.TOKEN_KEY, { expiresIn });
};
