const foodRepository = require("../repositories/food.repository");
const seedFoods = require("../src/seedFoods");
const httpError = require("../utils/httpError");

function publicFood(food) {
  const price = Number(food.price || 0);
  return {
    id: Number(food.id || 0),
    name: String(food.name || ""),
    price,
    originalPrice: Number(food.originalPrice || price),
    image: String(food.image || ""),
    category: String(food.category || "Món ngon"),
    restaurant: String(food.restaurant || "Order Food Kitchen"),
    description: String(food.description || ""),
    rating: Number(food.rating || 4.7),
    sold: Number(food.sold || 0),
    discountPercent: Number(food.discountPercent || 0),
    tags: Array.isArray(food.tags) ? food.tags : [],
    active: food.active !== false,
    createdAt: food.createdAt || new Date().toISOString(),
    updatedAt: food.updatedAt || food.createdAt || new Date().toISOString(),
  };
}

async function seedFoodsIfNeeded() {
  const existing = await foodRepository.list(1);
  if (existing.length > 0) return;

  const now = new Date().toISOString();
  await Promise.all(
    seedFoods.map((food) =>
      foodRepository.save(publicFood({ ...food, active: true, createdAt: now, updatedAt: now })),
    ),
  );
}

async function listFoods(options = {}) {
  const includeInactive = options.includeInactive === true;
  await seedFoodsIfNeeded();

  const foods = await foodRepository.list(500);
  return foods
    .map(publicFood)
    .filter((food) => includeInactive || food.active)
    .sort((a, b) => a.id - b.id);
}

function nextFoodId(foods) {
  return Math.max(0, ...foods.map((food) => Number(food.id || 0))) + 1;
}

function foodPayload(body, existing = {}) {
  const now = new Date().toISOString();
  const price = Number(body.price ?? existing.price ?? 0);
  return publicFood({
    ...existing,
    id: Number(existing.id || body.id || 0),
    name: body.name ?? existing.name,
    price,
    originalPrice: Number(body.originalPrice ?? existing.originalPrice ?? price),
    image: body.image ?? existing.image,
    category: body.category ?? existing.category,
    restaurant: body.restaurant ?? existing.restaurant,
    description: body.description ?? existing.description,
    rating: Number(body.rating ?? existing.rating ?? 4.7),
    sold: Number(body.sold ?? existing.sold ?? 0),
    discountPercent: Number(body.discountPercent ?? existing.discountPercent ?? 0),
    tags: Array.isArray(body.tags)
      ? body.tags
      : String(body.tags ?? existing.tags?.join(",") ?? "Giao nhanh")
          .split(",")
          .map((tag) => tag.trim())
          .filter(Boolean),
    active: body.active ?? existing.active ?? true,
    createdAt: existing.createdAt || now,
    updatedAt: now,
  });
}

async function findFoodById(id) {
  return foodRepository.findById(id);
}

async function saveFood(food) {
  return foodRepository.save(publicFood(food));
}

async function getFoods(queryParams = {}) {
  const { category, q } = queryParams;
  const query = String(q || "").trim().toLowerCase();
  const includeInactive = String(queryParams.includeInactive || "") === "true";
  const foods = await listFoods({ includeInactive });

  return foods.filter((food) => {
    const matchCategory = !category || category === "Tất cả" || food.category === category;
    const matchQuery =
      !query ||
      food.name.toLowerCase().includes(query) ||
      food.restaurant.toLowerCase().includes(query) ||
      food.category.toLowerCase().includes(query);
    return matchCategory && matchQuery;
  });
}

async function searchFoods(keyword) {
  const query = String(keyword || "").trim().toLowerCase();
  const foods = await listFoods();

  return foods.filter(
    (food) =>
      !query ||
      food.name.toLowerCase().includes(query) ||
      food.category.toLowerCase().includes(query) ||
      food.restaurant.toLowerCase().includes(query),
  );
}

async function getFoodDetail(id) {
  const food = await findFoodById(id);
  if (!food || food.active === false) {
    throw httpError(404, "Không tìm thấy món ăn");
  }

  return publicFood(food);
}

async function createFood(body) {
  if (!body.name || !Number(body.price)) {
    throw httpError(400, "Tên món và giá món là bắt buộc");
  }

  const foods = await listFoods({ includeInactive: true });
  const food = foodPayload({ ...body, id: nextFoodId(foods) });
  const saved = await saveFood(food);
  return { message: "Thêm món ăn thành công", food: saved };
}

async function updateFood(id, body) {
  const existing = await findFoodById(id);
  if (!existing) {
    throw httpError(404, "Không tìm thấy món ăn");
  }

  const saved = await saveFood(foodPayload(body, existing));
  return { message: "Cập nhật món ăn thành công", food: saved };
}

async function hideFood(id) {
  const existing = await findFoodById(id);
  if (!existing) {
    throw httpError(404, "Không tìm thấy món ăn");
  }

  const saved = await saveFood(foodPayload({ active: false }, existing));
  return { message: "Đã ẩn món ăn", food: saved };
}

module.exports = {
  publicFood,
  seedFoodsIfNeeded,
  listFoods,
  nextFoodId,
  foodPayload,
  findFoodById,
  saveFood,
  getFoods,
  searchFoods,
  getFoodDetail,
  createFood,
  updateFood,
  hideFood,
};
