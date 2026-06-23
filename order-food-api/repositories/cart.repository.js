const datastore = require("../config/datastore");
const COLLECTIONS = require("../constants/collections");

function cartKey(userId) {
  return datastore.key([COLLECTIONS.CARTS, String(userId || "").trim()]);
}

async function findByUserId(userId) {
  const [cart] = await datastore.get(cartKey(userId));
  return cart || { userId, items: [], updatedAt: new Date().toISOString() };
}

async function save(cart) {
  await datastore.save({ key: cartKey(cart.userId), data: cart });
  return cart;
}

async function remove(userId) {
  await datastore.delete(cartKey(userId));
}

module.exports = {
  findByUserId,
  save,
  remove,
};
