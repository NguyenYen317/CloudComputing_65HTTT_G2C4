const { getDatastore } = require("../config/datastore");
const COLLECTIONS = require("../constants/collections");

const LATEST_ID = "latest";

function predictionKey(id = LATEST_ID) {
  return getDatastore().key([COLLECTIONS.PREDICTIONS, id]);
}

async function getLatest() {
  const datastore = getDatastore();
  const [entity] = await datastore.get(predictionKey());
  if (!entity?.json) return null;
  return JSON.parse(entity.json);
}

async function saveLatest(predictions) {
  const data = {
    ...predictions,
    updatedAt: new Date().toISOString(),
  };

  const datastore = getDatastore();
  await datastore.save({
    key: predictionKey(),
    data: {
      id: LATEST_ID,
      json: JSON.stringify(data),
      updatedAt: data.updatedAt,
    },
  });

  return data;
}

module.exports = {
  getLatest,
  saveLatest,
};
