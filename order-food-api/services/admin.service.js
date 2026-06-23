const userRepository = require("../repositories/user.repository");
const orderRepository = require("../repositories/order.repository");
const authService = require("./auth.service");
const foodService = require("./food.service");
const orderService = require("./order.service");
const mlService = require("./ml.service");

async function getDashboard() {
  const [users, foods, orders] = await Promise.all([
    userRepository.list(500),
    foodService.listFoods({ includeInactive: true }),
    orderRepository.list(),
  ]);

  const revenue = orders.reduce(
    (sum, order) => sum + Number(order.totalAmount || order.total || 0),
    0,
  );

  return {
    totalUsers: users.length,
    totalFoods: foods.length,
    totalOrders: orders.length,
    revenue,
  };
}

async function listUsers() {
  return authService.listUsers(200);
}

async function removeUser(userId) {
  return authService.removeUser(userId);
}

async function listFoods() {
  return foodService.listFoods({ includeInactive: true });
}

async function listOrders() {
  return orderService.listAdminOrders();
}

async function getRevenue() {
  return orderService.revenueSummary();
}

async function getBestSellingFoods() {
  const foods = await foodService.listFoods();
  return [...foods].sort((a, b) => Number(b.sold || 0) - Number(a.sold || 0)).slice(0, 10);
}

async function getSuggestions() {
  const predictions = await mlService.getLatestPredictions();
  return { suggestions: predictions?.suggestions || [] };
}

module.exports = {
  getDashboard,
  listUsers,
  removeUser,
  listFoods,
  listOrders,
  getRevenue,
  getBestSellingFoods,
  getSuggestions,
};
