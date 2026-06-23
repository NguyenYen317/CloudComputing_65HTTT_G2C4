/**
 * Zoho CRM Routes
 * Defines all endpoints for Zoho CRM integration
 */

const express = require("express");
const router = express.Router();
const zohoController = require("../controllers/zoho.controller");
const authMiddleware = require("../middlewares/auth.middleware");

// Health check (no auth required)
router.get("/health", zohoController.zohoHealth);

// Customer operations
router.post("/customers", authMiddleware, zohoController.syncCustomer);

// Restaurant operations
router.post("/restaurants", authMiddleware, zohoController.syncRestaurant);

// Order operations
router.post("/orders", authMiddleware, zohoController.createZohoOrder);
router.patch("/orders/:zohoOrderId", authMiddleware, zohoController.updateZohoOrderStatus);

// Customer orders
router.get(
  "/customers/:contactId/orders",
  authMiddleware,
  zohoController.getCustomerZohoOrders
);

// Delivery tracking
router.post("/tasks", authMiddleware, zohoController.createDeliveryTracking);

module.exports = router;
