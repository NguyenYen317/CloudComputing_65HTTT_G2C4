const express = require("express");
const foodController = require("../controllers/food.controller");

const router = express.Router();

router.get("/", foodController.listFoods);
router.get("/search", foodController.searchFoods);
router.get("/:id", foodController.getFoodDetail);

module.exports = router;
