const { enablePubSub, pubSubOrderEventsTopic, serviceName } = require("../config/env");
const { normalizeOrderStatus } = require("../utils/orderHelpers");

let cachedPubSub = null;
let pubSubLoadFailed = false;

function getPubSubClient() {
  if (!enablePubSub) return null;
  if (cachedPubSub || pubSubLoadFailed) return cachedPubSub;

  try {
    const { PubSub } = require("@google-cloud/pubsub");
    cachedPubSub = new PubSub();
  } catch (error) {
    pubSubLoadFailed = true;
    console.warn(
      JSON.stringify({
        severity: "WARNING",
        service: serviceName,
        event: "pubsub_dependency_missing",
        message: error.message,
      }),
    );
  }

  return cachedPubSub;
}

function buildOrderPayload(order = {}, extra = {}) {
  return {
    orderId: order.id || order.code || "",
    userId: order.userId || "",
    userEmail: order.userEmail || order.email || "",
    status: normalizeOrderStatus(order),
    totalAmount: Number(order.totalAmount ?? order.total ?? 0),
    shipperId: order.shipperId || "",
    shipperEmail: order.shipperEmail || "",
    ...extra,
  };
}

async function publishEvent(eventType, payload = {}) {
  const message = {
    eventType,
    ...payload,
    createdAt: payload.createdAt || new Date().toISOString(),
    source: "cloud-run-backend",
    service: serviceName,
  };

  const pubSub = getPubSubClient();
  if (!pubSub) {
    console.warn(
      JSON.stringify({
        severity: "WARNING",
        service: serviceName,
        event: "pubsub_publish_skipped",
        eventType,
        topic: pubSubOrderEventsTopic,
      }),
    );
    return { skipped: true };
  }

  try {
    const messageId = await pubSub
      .topic(pubSubOrderEventsTopic)
      .publishMessage({ json: message });

    console.log(
      JSON.stringify({
        severity: "INFO",
        service: serviceName,
        event: "pubsub_published",
        eventType,
        topic: pubSubOrderEventsTopic,
        messageId,
      }),
    );

    return { messageId };
  } catch (error) {
    console.error(
      JSON.stringify({
        severity: "ERROR",
        service: serviceName,
        event: "pubsub_publish_failed",
        eventType,
        topic: pubSubOrderEventsTopic,
        error: error.message,
      }),
    );
    return { error: error.message };
  }
}

async function publishOrderEvent(eventType, order, extra = {}) {
  return publishEvent(eventType, buildOrderPayload(order, extra));
}

module.exports = {
  publishEvent,
  publishOrderEvent,
};
