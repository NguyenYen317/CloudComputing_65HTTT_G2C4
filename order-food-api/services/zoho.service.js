/**
 * Zoho CRM Service
 * Handles all Zoho CRM API operations for OrderFood
 */

const {
  zohoClientId,
  zohoClientSecret,
  zohoRefreshToken,
  zohoOrgId,
  zohoAccountServer,
  zohoCrmServer,
  ZOHO_MODULES,
  CUSTOM_FIELDS,
  isZohoEnabled,
} = require("../config/zoho");

const httpError = require("../utils/httpError");

let accessToken = null;
let tokenExpiry = null;

/**
 * Get access token from Zoho OAuth2
 */
async function getAccessToken() {
  try {
    // Return cached token if still valid
    if (accessToken && tokenExpiry && Date.now() < tokenExpiry) {
      return accessToken;
    }

    const response = await fetch(`${zohoAccountServer}/oauth/v2/token`, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({
        client_id: zohoClientId,
        client_secret: zohoClientSecret,
        refresh_token: zohoRefreshToken,
        grant_type: "refresh_token",
      }).toString(),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Zoho auth failed: ${error}`);
    }

    const data = await response.json();
    accessToken = data.access_token;
    tokenExpiry = Date.now() + (data.expires_in - 300) * 1000; // Refresh 5 min before expiry

    return accessToken;
  } catch (error) {
    console.error("Error getting Zoho access token:", error);
    throw error;
  }
}

/**
 * Make API call to Zoho CRM
 */
async function makeZohoRequest(method, endpoint, data = null) {
  try {
    if (!isZohoEnabled) {
      throw new Error("Zoho CRM is not configured");
    }

    const token = await getAccessToken();
    const url = `${zohoCrmServer}/crm/v2${endpoint}`;

    const options = {
      method,
      headers: {
        Authorization: `Zoho-oauthtoken ${token}`,
        "Content-Type": "application/json",
      },
    };

    if (data) {
      options.body = JSON.stringify(data);
    }

    const response = await fetch(url, options);

    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(
        `Zoho API error: ${errorData.message || response.statusText}`
      );
    }

    return await response.json();
  } catch (error) {
    console.error("Zoho API request failed:", error);
    throw error;
  }
}

/**
 * Create a new Contact (Customer) in Zoho CRM
 */
async function createCustomer(customerData) {
  try {
    const payload = {
      data: [
        {
          First_Name: customerData.firstName || "",
          Last_Name: customerData.lastName || "",
          Email: customerData.email,
          Phone: customerData.phone,
          Mailing_City: customerData.city,
          Mailing_State: customerData.state,
          Mailing_Zip: customerData.zipCode,
          [CUSTOM_FIELDS.DELIVERY_ADDRESS]: customerData.deliveryAddress,
          Description: `OrderFood Customer - ID: ${customerData.userId}`,
        },
      ],
    };

    const response = await makeZohoRequest(
      "POST",
      `/Contacts`,
      payload
    );

    return response.data[0];
  } catch (error) {
    console.error("Error creating Zoho contact:", error);
    throw error;
  }
}

/**
 * Create Order (Deal) in Zoho CRM
 */
async function createOrder(orderData) {
  try {
    const payload = {
      data: [
        {
          Deal_Name: `Order-${orderData.orderId}`,
          Account_Name: orderData.restaurantId,
          Contact_Name: orderData.customerId,
          Amount: orderData.totalAmount,
          Closing_Date: new Date().toISOString().split("T")[0],
          Stage: "Negotiation",
          [CUSTOM_FIELDS.ORDER_STATUS]: orderData.status || "Pending",
          [CUSTOM_FIELDS.DELIVERY_ADDRESS]: orderData.deliveryAddress,
          [CUSTOM_FIELDS.ESTIMATED_DELIVERY]: orderData.estimatedDelivery,
          [CUSTOM_FIELDS.SHIPPER_INFO]: orderData.shipperId,
          [CUSTOM_FIELDS.PAYMENT_METHOD]: orderData.paymentMethod,
          [CUSTOM_FIELDS.ORDER_VALUE]: orderData.totalAmount,
          Description: `Items: ${orderData.items.length} | Created from OrderFood App`,
        },
      ],
    };

    const response = await makeZohoRequest(
      "POST",
      `/Deals`,
      payload
    );

    return response.data[0];
  } catch (error) {
    console.error("Error creating Zoho order:", error);
    throw error;
  }
}

/**
 * Update Order Status in Zoho CRM
 */
async function updateOrderStatus(orderZohoId, status, additionalData = {}) {
  try {
    const stageMap = {
      pending: "Negotiation",
      confirmed: "Proposal",
      preparing: "Proposal",
      on_the_way: "Proposal",
      delivered: "Closed Won",
      cancelled: "Closed Lost",
    };

    const payload = {
      data: [
        {
          id: orderZohoId,
          Stage: stageMap[status] || "Negotiation",
          [CUSTOM_FIELDS.ORDER_STATUS]: status,
          [CUSTOM_FIELDS.ACTUAL_DELIVERY]:
            additionalData.actualDelivery || null,
          ...additionalData,
        },
      ],
    };

    const response = await makeZohoRequest(
      "PUT",
      `/Deals`,
      payload
    );

    return response.data[0];
  } catch (error) {
    console.error("Error updating Zoho order:", error);
    throw error;
  }
}

/**
 * Get Customer info from Zoho CRM by Email
 */
async function getCustomerByEmail(email) {
  try {
    const response = await makeZohoRequest(
      "GET",
      `/Contacts/search?email=${encodeURIComponent(email)}`
    );

    if (response.data && response.data.length > 0) {
      return response.data[0];
    }
    return null;
  } catch (error) {
    console.error("Error getting customer from Zoho:", error);
    throw error;
  }
}

/**
 * Get Order (Deal) by ID from Zoho CRM
 */
async function getOrder(dealId) {
  try {
    const response = await makeZohoRequest("GET", `/Deals/${dealId}`);
    return response.data[0];
  } catch (error) {
    console.error("Error getting order from Zoho:", error);
    throw error;
  }
}

/**
 * Create a Task for tracking shipment
 */
async function createDeliveryTask(taskData) {
  try {
    const payload = {
      data: [
        {
          Subject: `Delivery - Order ${taskData.orderId}`,
          Description: `Shipper: ${taskData.shipperName}\nPhone: ${taskData.shipperPhone}\nDelivery to: ${taskData.deliveryAddress}`,
          Due_Date: new Date(
            Date.now() + 24 * 60 * 60 * 1000
          )
            .toISOString()
            .split("T")[0],
          Status: "In Progress",
          Priority: "Medium",
          Related_To: taskData.dealId,
        },
      ],
    };

    const response = await makeZohoRequest(
      "POST",
      `/Tasks`,
      payload
    );

    return response.data[0];
  } catch (error) {
    console.error("Error creating Zoho task:", error);
    throw error;
  }
}

/**
 * Get all orders for a customer
 */
async function getCustomerOrders(contactId) {
  try {
    const response = await makeZohoRequest(
      "GET",
      `/Deals?criteria=(Contact_Name:${contactId})`
    );

    return response.data || [];
  } catch (error) {
    console.error("Error getting customer orders from Zoho:", error);
    throw error;
  }
}

/**
 * Create Account (Restaurant) in Zoho CRM
 */
async function createRestaurant(restaurantData) {
  try {
    const payload = {
      data: [
        {
          Account_Name: restaurantData.name,
          Phone: restaurantData.phone,
          Email: restaurantData.email,
          Billing_City: restaurantData.city,
          Billing_State: restaurantData.state,
          Billing_Zip: restaurantData.zipCode,
          Billing_Street: restaurantData.address,
          Website: restaurantData.website,
          Description: `OrderFood Partner Restaurant - ID: ${restaurantData.restaurantId}`,
        },
      ],
    };

    const response = await makeZohoRequest(
      "POST",
      `/Accounts`,
      payload
    );

    return response.data[0];
  } catch (error) {
    console.error("Error creating Zoho restaurant:", error);
    throw error;
  }
}

module.exports = {
  // Auth
  getAccessToken,

  // Customers
  createCustomer,
  getCustomerByEmail,
  getCustomerOrders,

  // Orders
  createOrder,
  updateOrderStatus,
  getOrder,

  // Delivery
  createDeliveryTask,

  // Restaurants
  createRestaurant,

  // Utilities
  makeZohoRequest,
  isZohoEnabled,
};
