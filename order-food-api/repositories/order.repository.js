const { getDatastore } = require("../config/datastore");
const COLLECTIONS = require("../constants/collections");

function orderKey(orderId) {
  return getDatastore().key([COLLECTIONS.ORDERS, String(orderId || "").trim()]);
}

async function findById(orderId) {
  const [order] = await getDatastore().get(orderKey(orderId));
  return order || null;
}

async function list(limit = 500) {
  const datastore = getDatastore();
  const [orders] = await datastore.runQuery(datastore.createQuery(COLLECTIONS.ORDERS).limit(limit));
  return orders;
}

async function save(order) {
  const datastore = getDatastore();
  await datastore.save({ key: orderKey(order.id), data: order });
  return order;
}

async function remove(orderId) {
  const datastore = getDatastore();
  await datastore.delete(orderKey(orderId));
}

module.exports = {
  findById,
  list,
  save,
  remove,
};
