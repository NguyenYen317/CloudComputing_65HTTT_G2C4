const uploadService = require("../services/upload.service");
const handleControllerError = require("../utils/controllerError");

async function uploadFoodImage(req, res) {
  try {
    res.json(await uploadService.uploadFoodImage(req.body));
  } catch (error) {
    handleControllerError(res, error);
  }
}

module.exports = {
  uploadFoodImage,
};
