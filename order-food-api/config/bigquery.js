let bigquery = null;

function getBigQuery() {
  if (bigquery) return bigquery;
  const { BigQuery } = require("@google-cloud/bigquery");
  bigquery = new BigQuery();
  return bigquery;
}

module.exports = {
  getBigQuery,
};
