const adminService = require("../services/admin.service");
const mlService = require("../services/ml.service");
const handleControllerError = require("../utils/controllerError");

async function getDashboard(req, res) {
  try {
    res.json(await adminService.getDashboard());
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function listUsers(req, res) {
  try {
    res.json(await adminService.listUsers());
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function removeUser(req, res) {
  try {
    res.json(await adminService.removeUser(req.params.userId || req.params.email));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function listFoods(req, res) {
  try {
    res.json(await adminService.listFoods());
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function listOrders(req, res) {
  try {
    res.json(await adminService.listOrders());
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function getRevenue(req, res) {
  try {
    res.json(await adminService.getRevenue());
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function getBestSellingFoods(req, res) {
  try {
    res.json(await adminService.getBestSellingFoods());
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function getSuggestions(req, res) {
  try {
    res.json(await adminService.getSuggestions());
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function getMlPredictions(req, res) {
  try {
    const data = await mlService.getPredictions(
      "Chưa có dữ liệu dự đoán. Vui lòng cập nhật dự đoán ML.",
    );
    res.json(data);
  } catch (error) {
    if (error.status) {
      return res.status(error.status).json({ message: error.message });
    }

    res.status(500).json({
      message: "Không đọc được dữ liệu dự đoán ML.",
      error: error.message,
    });
  }
}

async function trainMlModel(req, res) {
  try {
    const { rows, data } = await mlService.trainModel();
    return res.json({
      message: "Huấn luyện lại model ML thành công",
      rows,
      data,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Huấn luyện lại model ML thất bại",
      error: error.message,
    });
  }
}

async function updateMlPredictions(req, res) {
  try {
    const result = await mlService.updatePredictionsWithFallback();
    if (result.fallback) {
      return res.json({
        message: "Cập nhật dự đoán ML thành công bằng dữ liệu đã train sẵn",
        data: result.data,
        warning: result.warning,
      });
    }

    return res.json({ message: "Cập nhật dự đoán ML thành công", data: result.data });
  } catch (error) {
    return res.status(500).json({
      message: "Cập nhật dự đoán ML thất bại",
      error: error.message,
    });
  }
}

module.exports = {
  getDashboard,
  listUsers,
  removeUser,
  listFoods,
  listOrders,
  getRevenue,
  getBestSellingFoods,
  getSuggestions,
  getMlPredictions,
  trainMlModel,
  updateMlPredictions,
};
