const mapsService = require("../services/maps.service");
const orderRepository = require("../repositories/order.repository");
const handleControllerError = require("../utils/controllerError");

async function geocode(req, res) {
  try {
    const result = await mapsService.geocodeAddress(req.query.address);
    if (!result) {
      return res.status(404).json({ message: "Không lấy được tọa độ từ địa chỉ" });
    }

    return res.json(result);
  } catch (error) {
    return handleControllerError(res, error);
  }
}

async function directionsUrl(req, res) {
  try {
    const order = await orderRepository.findById(req.query.orderId);
    if (!order) {
      return res.status(404).json({ message: "Không tìm thấy đơn hàng" });
    }

    const result = await mapsService.enrichOrderWithMapData(order);
    return res.json({ mapsDirectionsUrl: result.order.mapsDirectionsUrl });
  } catch (error) {
    return handleControllerError(res, error);
  }
}

module.exports = {
  geocode,
  directionsUrl,
};
