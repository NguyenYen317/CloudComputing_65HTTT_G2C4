const path = require("path");
const { foodImageBucket } = require("../config/env");
const { foodImageFile, publicFoodImageUrl } = require("./storage.service");
const httpError = require("../utils/httpError");

function safeFileName(fileName) {
  return path.basename(String(fileName || "image.jpg")).replace(/[^a-zA-Z0-9._-]/g, "-");
}

async function uploadFoodImage({ fileName, contentType, dataBase64 }) {
  if (!foodImageBucket) {
    throw httpError(500, "Chưa cấu hình FOOD_IMAGE_BUCKET");
  }

  if (!fileName || !dataBase64) {
    throw httpError(400, "Thiếu file ảnh");
  }

  const objectName = `foods/${Date.now()}-${safeFileName(fileName)}`;
  const file = foodImageFile(objectName);
  const buffer = Buffer.from(String(dataBase64), "base64");

  await file.save(buffer, {
    metadata: {
      contentType: contentType || "image/jpeg",
      cacheControl: "public, max-age=31536000",
    },
    resumable: false,
  });

  return {
    message: "Upload ảnh món ăn thành công",
    imageUrl: publicFoodImageUrl(objectName),
  };
}

module.exports = {
  safeFileName,
  uploadFoodImage,
};
