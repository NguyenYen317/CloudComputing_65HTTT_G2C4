const express = require("express");
const cartController = require("../controllers/cart.controller");

const router = express.Router();

router.get("/", cartController.getCartByQuery);
router.put("/", cartController.replaceCart);
router.get("/:userId", cartController.getCart);
router.post("/:userId/items", cartController.addItem);
router.patch("/:userId/items/:foodId", cartController.updateItem);
router.delete("/:userId/items/:foodId", cartController.removeItem);
router.delete("/:userId", cartController.clearCart);

module.exports = router;
