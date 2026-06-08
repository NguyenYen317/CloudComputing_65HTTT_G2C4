const foodService = require("../services/food.service");
const handleControllerError = require("../utils/controllerError");

async function listFoods(req, res) {
  try {
    res.json(await foodService.getFoods(req.query));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function searchFoods(req, res) {
  try {
    res.json(await foodService.searchFoods(req.query.q));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function getFoodDetail(req, res) {
  try {
    res.json(await foodService.getFoodDetail(req.params.id));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function createFood(req, res) {
  try {
    res.json(await foodService.createFood(req.body));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function updateFood(req, res) {
  try {
    res.json(await foodService.updateFood(req.params.id || req.params.foodId, req.body));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function hideFood(req, res) {
  try {
    res.json(await foodService.hideFood(req.params.id || req.params.foodId));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function listAdminFoods(req, res) {
  try {
    res.json(await foodService.listFoods({ includeInactive: true }));
  } catch (error) {
    handleControllerError(res, error);
  }
}

module.exports = {
  listFoods,
  searchFoods,
  getFoodDetail,
  createFood,
  updateFood,
  hideFood,
  listAdminFoods,
};
