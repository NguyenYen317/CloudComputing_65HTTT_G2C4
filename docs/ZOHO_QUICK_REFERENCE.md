# Zoho CRM Integration - Quick Reference

## Files Created

1. **config/zoho.js** - Configuration and constants for Zoho CRM
2. **services/zoho.service.js** - Zoho CRM API service with core functions
3. **controllers/zoho.controller.js** - HTTP request handlers
4. **routes/zoho.routes.js** - API endpoints
5. **docs/zoho_crm_integration.md** - Detailed setup and usage guide

## Environment Variables Required

```env
ZOHO_CLIENT_ID=your_client_id
ZOHO_CLIENT_SECRET=your_client_secret
ZOHO_REFRESH_TOKEN=your_refresh_token
ZOHO_ORG_ID=your_org_id
ZOHO_ACCOUNTS_SERVER=https://accounts.zoho.com
ZOHO_CRM_SERVER=https://www.zohoapis.com
```

## Core Functions Available

### Authentication
- `getAccessToken()` - Get/refresh OAuth token

### Customer Management
- `createCustomer(data)` - Add customer to Zoho
- `getCustomerByEmail(email)` - Retrieve customer
- `getCustomerOrders(contactId)` - Get customer's orders

### Order Management
- `createOrder(data)` - Create new order/deal
- `updateOrderStatus(orderId, status)` - Update order status
- `getOrder(dealId)` - Retrieve order details

### Delivery Tracking
- `createDeliveryTask(data)` - Create tracking task

### Restaurant Management
- `createRestaurant(data)` - Add restaurant/account

## Quick Start Integration

### 1. Update .env file
```env
ZOHO_CLIENT_ID=your_id
ZOHO_CLIENT_SECRET=your_secret
ZOHO_REFRESH_TOKEN=your_token
ZOHO_ORG_ID=your_org_id
```

### 2. Test connection
```bash
curl http://localhost:8080/zoho/health
```

### 3. Sync a customer
```bash
curl -X POST http://localhost:8080/zoho/customers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer JWT_TOKEN" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "phone": "+84123456789",
    "deliveryAddress": "123 Main St"
  }'
```

### 4. Create an order
```bash
curl -X POST http://localhost:8080/zoho/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer JWT_TOKEN" \
  -d '{
    "orderId": "order_123",
    "customerId": "contact_id_from_step_3",
    "restaurantId": "rest_123",
    "totalAmount": 500000,
    "deliveryAddress": "123 Main St",
    "status": "pending"
  }'
```

## API Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/zoho/health` | Check connection |
| POST | `/zoho/customers` | Add customer |
| POST | `/zoho/restaurants` | Add restaurant |
| POST | `/zoho/orders` | Create order |
| PATCH | `/zoho/orders/:id` | Update order |
| GET | `/zoho/customers/:id/orders` | Get orders |
| POST | `/zoho/tasks` | Create task |

## Data Flow

```
OrderFood System
    ↓
Zoho CRM Service
    ↓
Zoho CRM API (OAuth2)
    ↓
Zoho CRM Database
```

## Features

✅ OAuth 2.0 authentication with auto-refresh
✅ CRUD operations for Contacts, Deals, Accounts, Tasks
✅ Custom fields for order tracking
✅ Automatic token management
✅ Error handling and validation
✅ Integration with existing OrderFood services

## Next Steps for Integration

1. **Get Zoho Credentials** - Follow the setup guide
2. **Create Custom Fields** - Add Order_Status, Delivery_Address, etc. to Zoho
3. **Add Environment Variables** - Set credentials in .env
4. **Test Endpoints** - Verify all APIs work
5. **Integrate with Order Service** - Auto-sync orders when created
6. **Add Webhooks** - Listen to Zoho CRM events (optional)

## Files Modified

- `app.js` - Added Zoho routes

## Support

For detailed setup instructions, see: `docs/zoho_crm_integration.md`
