const datastore = require("../config/datastore");
const COLLECTIONS = require("../constants/collections");

function userKey(email) {
  return datastore.key([COLLECTIONS.USERS, String(email || "").trim().toLowerCase()]);
}

async function findByEmail(email) {
  const [user] = await datastore.get(userKey(email));
  return user || null;
}

async function list(limit = 200) {
  const [users] = await datastore.runQuery(datastore.createQuery(COLLECTIONS.USERS).limit(limit));
  return users;
}

async function save(user) {
  await datastore.save({ key: userKey(user.email), data: user });
  return user;
}

async function remove(email) {
  await datastore.delete(userKey(email));
}

module.exports = {
  findByEmail,
  list,
  save,
  remove,
};
