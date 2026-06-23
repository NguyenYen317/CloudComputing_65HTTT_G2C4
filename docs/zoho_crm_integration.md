# Zoho CRM Integration Guide

## Overview
This guide explains how to set up and use Zoho CRM integration with the OrderFood API.

## Prerequisites
- Zoho CRM account (https://www.zoho.com/crm/)
- Admin access to create OAuth applications

## Setup Steps

### 1. Create OAuth Application in Zoho
1. Go to [Zoho Developer Console](https://api-console.zoho.com/)
2. Click **Add Client** → **Server-based Applications**
3. Set up application:
   - **Client Name**: OrderFood API
   - **Company Name**: Your Company
   - **Authorized Redirect URIs**: 
     ```
     http://localhost:8080/auth/zoho/callback
     https://yourdomain.com/auth/zoho/callback
     ```
4. Save and note down:
   - **Client ID**
   - **Client Secret**

### 2. Get Authorization Code
1. Visit the authorization URL in your browser:
   ```
   https://accounts.zoho.com/oauth/v2/auth?
   response_type=code&
   client_id={CLIENT_ID}&
   scope=ZohoCRM.modules.ALL,ZohoCRM.settings.all&
   redirect_uri={REDIRECT_URI}&
   access_type=offline
   ```

2. Grant permissions and copy the authorization code from the redirect URL

### 3. Exchange Code for Refresh Token
Run this curl command to get the refresh token:
```bash
curl -X POST https://accounts.zoho.com/oauth/v2/token \
  -d "code={AUTHORIZATION_CODE}" \
  -d "client_id={CLIENT_ID}" \
  -d "client_secret={CLIENT_SECRET}" \
  -d "redirect_uri={REDIRECT_URI}" \
  -d "grant_type=authorization_code"
```

Save the `refresh_token` from the response.

### 4. Add Environment Variables
Create or update `.env` file with:
```env
ZOHO_CLIENT_ID=your_client_id
ZOHO_CLIENT_SECRET=your_client_secret
ZOHO_REFRESH_TOKEN=your_refresh_token
ZOHO_ORG_ID=your_org_id
ZOHO_ACCOUNTS_SERVER=https://accounts.zoho.com
ZOHO_CRM_SERVER=https://www.zohoapis.com
```

To find your Org ID:
1. Log in to Zoho CRM
2. Go to Settings → Organization Info
3. Copy the Org ID

## API Endpoints

### 1. Health Check
```
GET /zoho/health
```
Check if Zoho CRM integration is working.

### 2. Sync Customer to Zoho
```
POST /zoho/customers
Content-Type: application/json

{
  "userId": "user_123",
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "phone": "+84123456789",
  "city": "Hanoi",
  "state": "HN",
  "zipCode": "100000",
  "deliveryAddress": "123 Main St, Hanoi"
}
```

### 3. Create Order in Zoho
```
POST /zoho/orders
Content-Type: application/json

{
  "orderId": "order_123",
  "customerId": "zoho_contact_id",
  "restaurantId": "restaurant_123",
  "totalAmount": 450000,
  "items": [
    { "name": "Pho", "quantity": 2, "price": 50000 }
  ],
  "deliveryAddress": "123 Main St",
  "estimatedDelivery": "2024-01-20T15:30:00Z",
  "status": "pending",
  "paymentMethod": "credit_card",
  "shipperId": "shipper_123"
}
```

### 4. Update Order Status
```
PATCH /zoho/orders/:zohoOrderId
Content-Type: application/json

{
  "status": "delivered",
  "actualDelivery": "2024-01-20T15:35:00Z",
  "shipperId": "shipper_123"
}
```

Status values: `pending`, `confirmed`, `preparing`, `on_the_way`, `delivered`, `cancelled`

### 5. Get Customer Orders
```
GET /zoho/customers/:contactId/orders
```

### 6. Create Delivery Task
```
POST /zoho/tasks
Content-Type: application/json

{
  "orderId": "order_123",
  "dealId": "zoho_deal_id",
  "shipperName": "John Shipper",
  "shipperPhone": "+84987654321",
  "deliveryAddress": "123 Main St",
  "shipperId": "shipper_123"
}
```

### 7. Sync Restaurant to Zoho
```
POST /zoho/restaurants
Content-Type: application/json

{
  "restaurantId": "rest_123",
  "name": "Pho Restaurant",
  "email": "info@pho.com",
  "phone": "+84912345678",
  "address": "456 Food Street",
  "city": "Hanoi",
  "state": "HN",
  "zipCode": "100000",
  "website": "https://pho.example.com"
}
```

## Custom Fields in Zoho CRM

The integration uses these custom fields in Zoho CRM Deals (Orders):

| Field Name | Type | Description |
|-----------|------|-------------|
| Delivery_Address | Text | Customer delivery address |
| Order_Status | Picklist | Current order status |
| Shipper_Info | Text | Shipper ID/info |
| Estimated_Delivery | DateTime | Expected delivery time |
| Actual_Delivery | DateTime | Actual delivery time |
| Order_Value | Currency | Total order amount |
| Payment_Method | Picklist | Payment method used |
| Restaurant_ID | Text | Restaurant identifier |

**To create these fields in Zoho CRM:**
1. Go to Setup → Customize → Deals
2. Click "+" to add new fields
3. Add each field with the names and types listed above

## Data Mapping

### Contacts (Customers)
- First_Name ← firstName
- Last_Name ← lastName
- Email ← email
- Phone ← phone
- Mailing_City ← city
- Mailing_State ← state
- Mailing_Zip ← zipCode
- Delivery_Address ← deliveryAddress (custom)

### Deals (Orders)
- Deal_Name ← "Order-{orderId}"
- Account_Name ← restaurantId
- Contact_Name ← customerId
- Amount ← totalAmount
- Stage ← Auto-mapped based on status
- Custom Fields ← Order details

### Accounts (Restaurants)
- Account_Name ← name
- Phone ← phone
- Email ← email
- Billing_City ← city
- Billing_State ← state
- Billing_Zip ← zipCode
- Billing_Street ← address
- Website ← website

## Error Handling

The integration includes error handling for:
- Missing Zoho credentials
- OAuth token expiration (auto-refresh)
- Network failures
- Invalid data format

## Troubleshooting

### "Zoho CRM is not configured"
- Check all environment variables are set correctly
- Verify credentials in Zoho Developer Console

### "Zoho API error: Invalid OAuth token"
- Your refresh token may be invalid or expired
- Re-generate the refresh token following step 3 in Setup

### "Zoho API error: INVALID_DATA"
- Check that all required fields are provided
- Verify data format matches Zoho expectations

### Token Expiration
- Access tokens auto-refresh when needed (5 min before expiry)
- Ensure refresh token is valid and stored correctly

## Testing

Test the health endpoint first:
```bash
curl http://localhost:8080/zoho/health
```

Then test customer sync:
```bash
curl -X POST http://localhost:8080/zoho/customers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "firstName": "Test",
    "lastName": "User",
    "email": "test@example.com",
    "phone": "+84123456789"
  }'
```

## References

- [Zoho CRM API Documentation](https://www.zoho.com/crm/developer/docs/api/overview.html)
- [OAuth 2.0 Flow](https://www.zoho.com/crm/developer/docs/server-side-sdk/auth.html)
- [Zoho CRM Modules](https://www.zoho.com/crm/developer/docs/api/modules.html)
