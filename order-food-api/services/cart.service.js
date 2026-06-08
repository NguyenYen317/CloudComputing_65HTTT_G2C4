const cartRepository = require("../repositories/cart.repository");
const httpError = require("../utils/httpError");

function normalizeUserId(userId) {
  return String(userId || "").trim();
}

async function findCartByUserId(userId) {
  return cartRepository.findByUserId(normalizeUserId(userId));
}

async function saveCart(cart) {
  return cartRepository.save(cart);
}

async function getCartByQuery(userId) {
  const normalizedUserId = normalizeUserId(userId);
  if (!normalizedUserId) {
    throw httpError(400, "Thiếu userId");
  }

  return findCartByUserId(normalizedUserId);
}

async function replaceCart(body) {
  const userId = normalizeUserId(body.userId);
  if (!userId) {
    throw httpError(400, "Thiếu userId");
  }

  const cart = await saveCart({
    userId,
    items: Array.isArray(body.items) ? body.items : [],
    updatedAt: new Date().toISOString(),
  });

  return { message: "Đã lưu giỏ hàng", cart };
}

async function addCartItem(userId, body) {
  const normalizedUserId = normalizeUserId(userId);
  const foodId = Number(body.foodId || body.id || 0);
  const quantity = Number(body.quantity || 1);

  if (!normalizedUserId || !foodId) {
    throw httpError(400, "Thiếu userId hoặc foodId");
  }

  const cart = await findCartByUserId(normalizedUserId);
  const existing = cart.items.find((item) => Number(item.foodId || item.id) === foodId);
  if (existing) existing.quantity = Number(existing.quantity || 0) + quantity;
  else cart.items.push({ foodId, quantity });
  cart.updatedAt = new Date().toISOString();

  return {
    message: "Đã thêm món vào giỏ hàng",
    cart: await saveCart(cart),
  };
}

async function updateCartItem(userId, foodId, body) {
  const normalizedUserId = normalizeUserId(userId);
  const normalizedFoodId = Number(foodId || 0);
  const quantity = Math.max(1, Number(body.quantity || 1));
  const cart = await findCartByUserId(normalizedUserId);

  cart.items = cart.items.map((item) =>
    Number(item.foodId || item.id) === normalizedFoodId ? { ...item, quantity } : item,
  );
  cart.updatedAt = new Date().toISOString();

  return {
    message: "Đã cập nhật giỏ hàng",
    cart: await saveCart(cart),
  };
}

async function removeCartItem(userId, foodId) {
  const normalizedUserId = normalizeUserId(userId);
  const normalizedFoodId = Number(foodId || 0);
  const cart = await findCartByUserId(normalizedUserId);

  cart.items = cart.items.filter((item) => Number(item.foodId || item.id) !== normalizedFoodId);
  cart.updatedAt = new Date().toISOString();

  return {
    message: "Đã xóa món khỏi giỏ hàng",
    cart: await saveCart(cart),
  };
}

async function clearCart(userId) {
  const normalizedUserId = normalizeUserId(userId);
  const cart = await saveCart({
    userId: normalizedUserId,
    items: [],
    updatedAt: new Date().toISOString(),
  });

  return { message: "Đã xóa giỏ hàng", cart };
}

module.exports = {
  normalizeUserId,
  findCartByUserId,
  saveCart,
  removeCart: cartRepository.remove,
  getCartByQuery,
  replaceCart,
  addCartItem,
  updateCartItem,
  removeCartItem,
  clearCart,
};
