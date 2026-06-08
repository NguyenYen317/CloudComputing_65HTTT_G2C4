const express = require("express");
const orderController = require("../controllers/order.controller");

const router = express.Router();

router.get("/", orderController.listOrders);
router.post("/", orderController.createOrder);
router.get("/detail/:orderId", orderController.getOrderDetail);
router.patch("/:id/cancel", orderController.cancelOrder);
router.delete("/:id", orderController.deleteOrder);
router.get("/:userId", orderController.listOrdersByUser);

module.exports = router;
