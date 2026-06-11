const notificationService = require("../services/notification.service");
const handleControllerError = require("../utils/controllerError");

async function saveToken(req, res) {
  try {
    res.json(await notificationService.saveFcmToken(req.body.userId, req.body.fcmToken));
  } catch (error) {
    handleControllerError(res, error);
  }
}

module.exports = {
  saveToken,
};
