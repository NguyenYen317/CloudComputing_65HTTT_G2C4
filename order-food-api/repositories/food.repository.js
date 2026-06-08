const datastore = require("../config/datastore");
const COLLECTIONS = require("../constants/collections");

function foodKey(id) {
  return datastore.key([COLLECTIONS.FOODS, String(id || "").trim()]);
}

async function findById(id) {
  const [food] = await datastore.get(foodKey(id));
  return food || null;
}

async function list(limit = 500) {
  const [foods] = await datastore.runQuery(datastore.createQuery(COLLECTIONS.FOODS).limit(limit));
  return foods;
}

async function save(food) {
  await datastore.save({ key: foodKey(food.id), data: food });
  return food;
}

module.exports = {
  findById,
  list,
  save,
};
