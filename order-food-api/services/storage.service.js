const storage = require("../config/storage");
const { foodImageBucket } = require("../config/env");

function foodImageFile(objectName) {
  if (!foodImageBucket) {
    throw new Error("Chưa cấu hình FOOD_IMAGE_BUCKET");
  }
  return storage.bucket(foodImageBucket).file(objectName);
}

function publicFoodImageUrl(objectName) {
  return `https://storage.googleapis.com/${foodImageBucket}/${objectName}`;
}

module.exports = {
  foodImageFile,
  publicFoodImageUrl,
};
