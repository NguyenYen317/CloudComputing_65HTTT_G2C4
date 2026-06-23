/**
 * Zoho CRM Controller
 * Handles HTTP requests for Zoho CRM operations
 */

const zohoService = require("../services/zoho.service");
const httpError = require("../utils/httpError");

/**
 * Sync customer to Zoho CRM
 * POST /api/zoho/customers
 */
async function syncCustomer(req, res, next) {
  try {
    if (!zohoService.isZohoEnabled) {
      throw httpError(400, "Zoho CRM is not configured");
    }

    const { userId, firstName, lastName, email, phone, city, state, zipCode, deliveryAddress } = req.body;

    if (!email || !firstName) {
      throw httpError(400, "Email and firstName are required");
    }

    // Check if customer already exists
    let existingCustomer = await zohoService.getCustomerByEmail(email);
    if (existingCustomer) {
      return res.json({
        success: true,
        message: "Customer already exists in Zoho CRM",
        zohoContactId: existingCustomer.id,
      });
    }

    // Create new customer
    const newContact = await zohoService.createCustomer({
      userId,
      firstName,
      lastName,
      email,
      phone,
      city,
      state,
      zipCode,
      deliveryAddress,
    });

    res.json({
      success: true,
      message: "Customer synced to Zoho CRM successfully",
      zohoContactId: newContact.id,
      contact: newContact,
    });
  } catch (error) {
    next(error);
  }
}

/**
 * Create order in Zoho CRM
 * POST /api/zoho/orders
 */
async function createZohoOrder(req, res, next) {
  try {
    if (!zohoService.isZohoEnabled) {
      throw httpError(400, "Zoho CRM is not configured");
    }

    const {
      orderId,
      customerId,
      restaurantId,
      totalAmount,
      items,
      deliveryAddress,
      estimatedDelivery,
      status,
      paymentMethod,
      shipperId,
    } = req.body;

    if (!orderId || !customerId || !restaurantId) {
      throw httpError(400, "orderId, customerId, and restaurantId are required");
    }

    const zohoDeal = await zohoService.createOrder({
      orderId,
      customerId,
      restaurantId,
      totalAmount,
      items,
      deliveryAddress,
      estimatedDelivery,
      status: status || "Pending",
      paymentMethod,
      shipperId,
    });

    res.json({
      success: true,
      message: "Order created in Zoho CRM",
      zohoOrderId: zohoDeal.id,
      order: zohoDeal,
    });
  } catch (error) {
    next(error);
  }
}

/**
 * Update order status in Zoho CRM
 * PATCH /api/zoho/orders/:zohoOrderId
 */
async function updateZohoOrderStatus(req, res, next) {
  try {
    if (!zohoService.isZohoEnabled) {
      throw httpError(400, "Zoho CRM is not configured");
    }

    const { zohoOrderId } = req.params;
    const { status, actualDelivery, shipperId } = req.body;

    if (!status) {
      throw httpError(400, "status is required");
    }

    const updatedDeal = await zohoService.updateOrderStatus(
      zohoOrderId,
      status,
      { actualDelivery, shipperId }
    );

    res.json({
      success: true,
      message: "Order status updated in Zoho CRM",
      order: updatedDeal,
    });
  } catch (error) {
    next(error);
  }
}

/**
 * Get customer orders from Zoho CRM
 * GET /api/zoho/customers/:contactId/orders
 */
async function getCustomerZohoOrders(req, res, next) {
  try {
    if (!zohoService.isZohoEnabled) {
      throw httpError(400, "Zoho CRM is not configured");
    }

    const { contactId } = req.params;

    const orders = await zohoService.getCustomerOrders(contactId);

    res.json({
      success: true,
      orders,
      total: orders.length,
    });
  } catch (error) {
    next(error);
  }
}

/**
 * Create delivery task in Zoho CRM
 * POST /api/zoho/tasks
 */
async function createDeliveryTracking(req, res, next) {
  try {
    if (!zohoService.isZohoEnabled) {
      throw httpError(400, "Zoho CRM is not configured");
    }

    const {
      orderId,
      dealId,
      shipperName,
      shipperPhone,
      deliveryAddress,
      shipperId,
    } = req.body;

    if (!orderId || !dealId) {
      throw httpError(400, "orderId and dealId are required");
    }

    const task = await zohoService.createDeliveryTask({
      orderId,
      dealId,
      shipperName,
      shipperPhone,
      deliveryAddress,
      shipperId,
    });

    res.json({
      success: true,
      message: "Delivery task created in Zoho CRM",
      zohoTaskId: task.id,
      task,
    });
  } catch (error) {
    next(error);
  }
}

/**
 * Sync restaurant to Zoho CRM
 * POST /api/zoho/restaurants
 */
async function syncRestaurant(req, res, next) {
  try {
    if (!zohoService.isZohoEnabled) {
      throw httpError(400, "Zoho CRM is not configured");
    }

    const {
      restaurantId,
      name,
      email,
      phone,
      address,
      city,
      state,
      zipCode,
      website,
    } = req.body;

    if (!restaurantId || !name) {
      throw httpError(400, "restaurantId and name are required");
    }

    const account = await zohoService.createRestaurant({
      restaurantId,
      name,
      email,
      phone,
      address,
      city,
      state,
      zipCode,
      website,
    });

    res.json({
      success: true,
      message: "Restaurant synced to Zoho CRM",
      zohoAccountId: account.id,
      account,
    });
  } catch (error) {
    next(error);
  }
}

/**
 * Health check for Zoho CRM integration
 * GET /api/zoho/health
 */
async function zohoHealth(req, res, next) {
  try {
    if (!zohoService.isZohoEnabled) {
      return res.status(400).json({
        success: false,
        message: "Zoho CRM is not configured",
      });
    }

    // Try to get access token to verify connection
    await zohoService.getAccessToken();

    res.json({
      success: true,
      message: "Zoho CRM integration is healthy",
      status: "connected",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Zoho CRM connection failed",
      error: error.message,
    });
  }
}

module.exports = {
  syncCustomer,
  createZohoOrder,
  updateZohoOrderStatus,
  getCustomerZohoOrders,
  createDeliveryTracking,
  syncRestaurant,
  zohoHealth,
};
