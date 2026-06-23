const express = require("express");
const bigqueryController = require("../controllers/bigquery.controller");
const authMiddleware = require("../middlewares/auth.middleware");
const adminMiddleware = require("../middlewares/admin.middleware");

const router = express.Router();
const adminOnly = [authMiddleware, adminMiddleware];

router.get("/order-events", ...adminOnly, bigqueryController.listOrderEvents);
router.post("/order-events", ...adminOnly, bigqueryController.createOrderEvent);
router.get("/revenue-summary", ...adminOnly, bigqueryController.revenueSummary);
router.get("/best-selling-foods", ...adminOnly, bigqueryController.bestSellingFoods);

module.exports = router;
