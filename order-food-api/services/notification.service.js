const userRepository = require("../repositories/user.repository");
const getFirebaseAdmin = require("../config/firebaseAdmin");
const httpError = require("../utils/httpError");
const { normalizeOrderStatus } = require("../utils/orderHelpers");
const { serviceName } = require("../config/env");

const STATUS_MESSAGES = {
  pending: "Đơn hàng của bạn đã được tạo thành công.",
  confirmed: "Đơn hàng của bạn đã được xác nhận.",
  preparing: "Nhà hàng đang chuẩn bị món ăn của bạn.",
  waiting_shipper: "Đơn hàng đã sẵn sàng và đang chờ shipper lấy hàng.",
  assigned_shipper: "Shipper đã nhận đơn hàng của bạn.",
  delivering: "Đơn hàng của bạn đang được giao.",
  completed: "Đơn hàng đã được giao thành công.",
  cancelled: "Đơn hàng đã được hủy.",
};

async function findUserByIdOrEmail(userId) {
  const normalized = String(userId || "").trim().toLowerCase();
  if (!normalized) return null;

  if (normalized.includes("@")) {
    return userRepository.findByEmail(normalized);
  }

  const users = await userRepository.list(500);
  return users.find((user) => String(user.id || "").toLowerCase() === normalized) || null;
}

async function saveFcmToken(userId, fcmToken) {
  const normalizedToken = String(fcmToken || "").trim();
  if (!userId || !normalizedToken) {
    throw httpError(400, "Thiếu userId hoặc fcmToken");
  }

  const user = await findUserByIdOrEmail(userId);
  if (!user) {
    throw httpError(404, "Không tìm thấy người dùng để lưu FCM token");
  }

  const updated = {
    ...user,
    fcmToken: normalizedToken,
    updatedAt: new Date().toISOString(),
  };

  await userRepository.save(updated);
  return { message: "Đã lưu FCM token", userId: updated.id, email: updated.email };
}

function normalizeData(data = {}) {
  return Object.fromEntries(
    Object.entries(data).map(([key, value]) => [key, String(value ?? "")]),
  );
}

async function sendNotificationToUser(userId, title, body, data = {}) {
  try {
    const user = await findUserByIdOrEmail(userId);
    const fcmToken = user?.fcmToken;

    if (!user || !fcmToken) {
      console.warn(
        JSON.stringify({
          severity: "WARNING",
          service: serviceName,
          event: "fcm_skipped_no_token",
          userId,
        }),
      );
      return { skipped: true, reason: "no_token" };
    }

    const firebaseAdmin = getFirebaseAdmin();
    if (!firebaseAdmin) {
      return { skipped: true, reason: "firebase_admin_unavailable" };
    }

    const messageId = await firebaseAdmin.messaging().send({
      token: fcmToken,
      notification: { title, body },
      data: normalizeData(data),
    });

    console.log(
      JSON.stringify({
        severity: "INFO",
        service: serviceName,
        event: "fcm_sent",
        userId: user.id,
        messageId,
      }),
    );

    return { messageId };
  } catch (error) {
    console.error(
      JSON.stringify({
        severity: "ERROR",
        service: serviceName,
        event: "fcm_send_failed",
        userId,
        error: error.message,
      }),
    );
    return { error: error.message };
  }
}

async function sendOrderStatusNotification(order) {
  const status = normalizeOrderStatus(order);
  const body = STATUS_MESSAGES[status];
  if (!body) return { skipped: true, reason: "unsupported_status" };

  const userId = order.userId || order.userEmail || order.email;
  if (!userId) return { skipped: true, reason: "missing_user" };

  return sendNotificationToUser(userId, "Order Food", body, {
    orderId: order.id || order.code || "",
    status,
  });
}

module.exports = {
  saveFcmToken,
  sendNotificationToUser,
  sendOrderStatusNotification,
};
