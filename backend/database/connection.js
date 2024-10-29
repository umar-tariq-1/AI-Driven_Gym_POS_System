const mysql = require("mysql2/promise");

async function connectDatabase() {
  try {
    const connectionConfig = {
      host: process.env.DB_HOST || "127.0.0.1",
      port: process.env.DB_PORT || 3306,
      user: process.env.DB_USER || "superBrain",
      password: process.env.DB_PASSWORD || "superBrain123",
    };

    const con = await mysql.createConnection(connectionConfig);
    console.log("Database Connected Successfully.");

    return con;
  } catch (error) {
    console.error("Error connecting to Database: ", error);
    throw new Error("Failed to connect to Database");
  }
}

module.exports = { connectDatabase };
