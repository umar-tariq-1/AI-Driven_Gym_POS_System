const jwt = require("jsonwebtoken");

module.exports.authorize = async (req, res, next) => {
  try {
    const db = req.db;
    const authToken = req.headers["auth-token"];

    if (!authToken) {
      return res.status(401).send({
        message: "Sorry, you are not logged in for this",
        isLoggedIn: false,
      });
    }

    jwt.verify(authToken, process.env.TOKEN_KEY, async (err, decoded) => {
      if (err) {
        return res.status(401).send({
          message: "Access token expired. Please login again!",
          isLoggedIn: false,
        });
      }

      const userId = decoded.id;

      const [user] = await db.query(
        "SELECT * FROM gym_pos_system.Users WHERE id = ?",
        [userId]
      );

      if (user.length > 0) {
        req.userData = user[0];
        next();
      } else {
        return res.status(401).send({
          message: "Sorry, you are not authorized for this",
          isLoggedIn: false,
        });
      }
    });
  } catch (err) {
    console.error(err);
    return res.status(500).send({
      message: "Internal server error",
    });
  }
};
