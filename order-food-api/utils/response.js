function ok(res, data, status = 200) {
  return res.status(status).json(data);
}

function created(res, data) {
  return ok(res, data, 201);
}

function fail(res, status, message, extra = {}) {
  return res.status(status).json({ message, ...extra });
}

module.exports = {
  ok,
  created,
  fail,
};
