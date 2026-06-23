const express = require("express");
const shipperController = require("../controllers/shipper.controller");
const authMiddleware = require("../middlewares/auth.middleware");
const shipperMiddleware = require("../middlewares/shipper.middleware");

const router = express.Router();
const shipperOnly = [authMiddleware, shipperMiddleware];

router.get("/orders/available", ...shipperOnly, shipperController.getAvailableOrders);
router.get("/orders/my-orders/:shipperId", ...shipperOnly, shipperController.getMyDeliveryOrders);
router.get("/orders/detail/:orderId", ...shipperOnly, shipperController.getDeliveryOrderDetail);
router.patch("/orders/:orderId/accept", ...shipperOnly, shipperController.acceptOrder);
router.patch("/orders/:orderId/delivering", ...shipperOnly, shipperController.startDelivering);
router.patch("/orders/:orderId/completed", ...shipperOnly, shipperController.completeOrder);

module.exports = router;
