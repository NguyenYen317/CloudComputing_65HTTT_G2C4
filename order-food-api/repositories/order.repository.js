const datastore = require("../config/datastore");
const COLLECTIONS = require("../constants/collections");

function orderKey(orderId) {
  return datastore.key([COLLECTIONS.ORDERS, String(orderId || "").trim()]);
}

async function findById(orderId) {
  const [order] = await datastore.get(orderKey(orderId));
  return order || null;
}

async function list(limit = 500) {
  const [orders] = await datastore.runQuery(datastore.createQuery(COLLECTIONS.ORDERS).limit(limit));
  return orders;
}

async function save(order) {
  await datastore.save({ key: orderKey(order.id), data: order });
  return order;
}

async function remove(orderId) {
  await datastore.delete(orderKey(orderId));
}

module.exports = {
  findById,
  list,
  save,
  remove,
};
