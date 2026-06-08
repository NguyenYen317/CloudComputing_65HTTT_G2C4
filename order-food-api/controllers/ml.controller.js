const mlService = require("../services/ml.service");
const handleControllerError = require("../utils/controllerError");

async function getPredictions(req, res) {
  try {
    const data = await mlService.getPredictions(
      "Chưa có dữ liệu dự đoán. Vui lòng chạy ML prediction trước.",
    );
    res.json(data);
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function trainModel(req, res) {
  try {
    const { rows, data } = await mlService.trainModel();
    res.json({ message: "Huấn luyện model ML thành công", rows, data });
  } catch (error) {
    res.status(500).json({ message: "Huấn luyện model ML thất bại", error: error.message });
  }
}

async function updatePredictions(req, res) {
  try {
    const data = await mlService.updatePredictions();
    res.json({ message: "Cập nhật dự đoán ML thành công", data });
  } catch (error) {
    res.status(500).json({ message: "Cập nhật dự đoán ML thất bại", error: error.message });
  }
}

module.exports = {
  getPredictions,
  trainModel,
  updatePredictions,
};
