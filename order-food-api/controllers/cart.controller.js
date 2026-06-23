const cartService = require("../services/cart.service");
const handleControllerError = require("../utils/controllerError");

async function getCartByQuery(req, res) {
  try {
    res.json(await cartService.getCartByQuery(req.query.userId));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function replaceCart(req, res) {
  try {
    res.json(await cartService.replaceCart(req.body));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function getCart(req, res) {
  try {
    res.json(await cartService.findCartByUserId(req.params.userId));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function addItem(req, res) {
  try {
    res.json(await cartService.addCartItem(req.params.userId, req.body));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function updateItem(req, res) {
  try {
    res.json(await cartService.updateCartItem(req.params.userId, req.params.foodId, req.body));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function removeItem(req, res) {
  try {
    res.json(await cartService.removeCartItem(req.params.userId, req.params.foodId));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function clearCart(req, res) {
  try {
    res.json(await cartService.clearCart(req.params.userId));
  } catch (error) {
    handleControllerError(res, error);
  }
}

module.exports = {
  getCartByQuery,
  replaceCart,
  getCart,
  addItem,
  updateItem,
  removeItem,
  clearCart,
};
