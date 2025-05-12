const express = require("express");
const { authorize } = require("../../middlewares/authorize");

const trainerRegisterGym = express.Router();

module.exports = trainerRegisterGym;
