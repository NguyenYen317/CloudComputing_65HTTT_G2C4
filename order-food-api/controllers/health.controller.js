function getHealth(req, res) {
  res.json({
    success: true,
    message: "Order Food API is healthy",
    timestamp: new Date().toISOString(),
  });
}

module.exports = {
  getHealth,
};
