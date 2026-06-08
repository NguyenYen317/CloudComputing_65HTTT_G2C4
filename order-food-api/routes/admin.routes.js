const express = require("express");
const adminController = require("../controllers/admin.controller");
const foodController = require("../controllers/food.controller");
const orderController = require("../controllers/order.controller");
const uploadController = require("../controllers/upload.controller");
const bigqueryController = require("../controllers/bigquery.controller");
const authMiddleware = require("../middlewares/auth.middleware");
const adminMiddleware = require("../middlewares/admin.middleware");

const router = express.Router();
const adminOnly = [authMiddleware, adminMiddleware];

router.get("/dashboard", ...adminOnly, adminController.getDashboard);
router.get("/users", ...adminOnly, adminController.listUsers);
router.delete("/users/:userId", ...adminOnly, adminController.removeUser);

router.post("/foods/upload-image", ...adminOnly, uploadController.uploadFoodImage);
router.get("/foods", ...adminOnly, adminController.listFoods);
router.post("/foods", ...adminOnly, foodController.createFood);
router.patch("/foods/:id", ...adminOnly, foodController.updateFood);
router.delete("/foods/:id", ...adminOnly, foodController.hideFood);

router.get("/orders", ...adminOnly, adminController.listOrders);
router.patch("/orders/:id/status", ...adminOnly, orderController.updateOrderStatus);

router.get("/revenue", ...adminOnly, adminController.getRevenue);
router.get("/best-selling-foods", ...adminOnly, adminController.getBestSellingFoods);
router.get("/suggestions", ...adminOnly, adminController.getSuggestions);

router.get("/ml-predictions", ...adminOnly, adminController.getMlPredictions);
router.post("/train-ml-model", ...adminOnly, adminController.trainMlModel);
router.post("/update-ml-predictions", ...adminOnly, adminController.updateMlPredictions);

router.get("/bigquery-summary", ...adminOnly, bigqueryController.getAdminSummary);
router.get("/bigquery-events", ...adminOnly, bigqueryController.getAdminEvents);

module.exports = router;
