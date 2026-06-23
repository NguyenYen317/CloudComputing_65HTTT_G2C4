/**
 * Zoho CRM Configuration
 * API Reference: https://www.zoho.com/crm/developer/docs/api/overview.html
 */

const zohoClientId = process.env.ZOHO_CLIENT_ID || "";
const zohoClientSecret = process.env.ZOHO_CLIENT_SECRET || "";
const zohoRefreshToken = process.env.ZOHO_REFRESH_TOKEN || "";
const zohoOrgId = process.env.ZOHO_ORG_ID || "";
const zohoAccountServer = process.env.ZOHO_ACCOUNTS_SERVER || "https://accounts.zoho.com";
const zohoCrmServer = process.env.ZOHO_CRM_SERVER || "https://www.zohoapis.com";

// Zoho CRM modules for OrderFood
const ZOHO_MODULES = {
  ACCOUNTS: "Accounts", // Restaurant/Store
  CONTACTS: "Contacts", // Customers
  DEALS: "Deals", // Orders
  TASKS: "Tasks", // Delivery tracking
  CUSTOM_ORDERS: "Orders", // Custom Orders module (if created)
};

// Custom fields mapping
const CUSTOM_FIELDS = {
  DELIVERY_ADDRESS: "Delivery_Address",
  ORDER_STATUS: "Order_Status",
  SHIPPER_INFO: "Shipper_Info",
  ESTIMATED_DELIVERY: "Estimated_Delivery",
  ACTUAL_DELIVERY: "Actual_Delivery",
  ORDER_VALUE: "Order_Value",
  PAYMENT_METHOD: "Payment_Method",
  RESTAURANT_ID: "Restaurant_ID",
};

module.exports = {
  zohoClientId,
  zohoClientSecret,
  zohoRefreshToken,
  zohoOrgId,
  zohoAccountServer,
  zohoCrmServer,
  ZOHO_MODULES,
  CUSTOM_FIELDS,
  isZohoEnabled:
    !!(zohoClientId && zohoClientSecret && zohoRefreshToken && zohoOrgId),
};
