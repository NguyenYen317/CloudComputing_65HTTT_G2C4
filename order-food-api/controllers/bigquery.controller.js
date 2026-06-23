const bigqueryService = require("../services/bigquery.service");
const handleControllerError = require("../utils/controllerError");

async function getAdminSummary(req, res) {
  try {
    res.json(await bigqueryService.getAdminSummary());
  } catch (error) {
    res.status(500).json({
      message: "Không đọc được thống kê BigQuery",
      error: error.message,
    });
  }
}

async function getAdminEvents(req, res) {
  try {
    res.json(await bigqueryService.listOrderEvents(req.query.limit));
  } catch (error) {
    res.status(500).json({
      message: "Không đọc được dữ liệu BigQuery",
      error: error.message,
    });
  }
}

async function listOrderEvents(req, res) {
  try {
    res.json(await bigqueryService.listOrderEvents(req.query.limit));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function createOrderEvent(req, res) {
  try {
    res.json(await bigqueryService.createOrderEvent(req.body));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function revenueSummary(req, res) {
  try {
    res.json(await bigqueryService.revenueSummary());
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function bestSellingFoods(req, res) {
  try {
    res.json(await bigqueryService.bestSellingFoods());
  } catch (error) {
    handleControllerError(res, error);
  }
}

module.exports = {
  getAdminSummary,
  getAdminEvents,
  listOrderEvents,
  createOrderEvent,
  revenueSummary,
  bestSellingFoods,
};
