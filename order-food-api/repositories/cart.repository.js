const { getDatastore } = require("../config/datastore");
const COLLECTIONS = require("../constants/collections");

function cartKey(userId) {
  return getDatastore().key([COLLECTIONS.CARTS, String(userId || "").trim()]);
}

async function findByUserId(userId) {
  const [cart] = await getDatastore().get(cartKey(userId));
  return cart || { userId, items: [], updatedAt: new Date().toISOString() };
}

async function save(cart) {
  const datastore = getDatastore();
  await datastore.save({ key: cartKey(cart.userId), data: cart });
  return cart;
}

async function remove(userId) {
  const datastore = getDatastore();
  await datastore.delete(cartKey(userId));
}

module.exports = {
  findByUserId,
  save,
  remove,
};
