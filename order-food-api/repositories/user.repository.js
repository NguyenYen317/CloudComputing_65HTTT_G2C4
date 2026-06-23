const { getDatastore } = require("../config/datastore");
const COLLECTIONS = require("../constants/collections");

function userKey(email) {
  return getDatastore().key([COLLECTIONS.USERS, String(email || "").trim().toLowerCase()]);
}

async function findByEmail(email) {
  console.log(JSON.stringify({ event: "user_repository_findByEmail", email }));
  const datastore = getDatastore();
  console.log(JSON.stringify({ event: "user_repository_datastore_type", type: datastore.constructor?.name }));
  const [user] = await datastore.get(userKey(email));
  console.log(JSON.stringify({ event: "user_repository_findByEmail_result", user: !!user }));
  return user || null;
}

async function list(limit = 200) {
  const datastore = getDatastore();
  const [users] = await datastore.runQuery(datastore.createQuery(COLLECTIONS.USERS).limit(limit));
  return users;
}

async function save(user) {
  const datastore = getDatastore();
  await datastore.save({ key: userKey(user.email), data: user });
  return user;
}

async function remove(email) {
  const datastore = getDatastore();
  await datastore.delete(userKey(email));
}

module.exports = {
  findByEmail,
  list,
  save,
  remove,
};
