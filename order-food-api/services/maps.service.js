const {
  googleMapsApiKey,
  defaultStoreLat,
  defaultStoreLng,
  defaultStoreAddress,
  serviceName,
} = require("../config/env");

function toNumber(value) {
  const number = Number(value);
  return Number.isFinite(number) ? number : null;
}

function normalizeAddress(address) {
  return String(address || "").trim();
}

function normalizeVietnamAddress(address) {
  const normalized = normalizeAddress(address);
  if (!normalized) return "";

  const lower = normalized.toLowerCase();
  if (
    lower.includes("viet nam") ||
    lower.includes("việt nam") ||
    lower.includes("viá»‡t nam")
  ) {
    return normalized;
  }

  return `${normalized}, Việt Nam`;
}

function knownVietnamLocation(address) {
  const normalized = normalizeAddress(address).toLowerCase();
  if (!normalized.includes("1002")) return null;

  if (
    normalized.includes("giải phóng") ||
    normalized.includes("giai phong") ||
    normalized.includes("giáº£i phÃ³ng")
  ) {
    return { lat: 20.98285, lng: 105.84184 };
  }

  return null;
}

function getCustomerAddress(order = {}) {
  return normalizeAddress(
    order.customerAddress ||
      order.address ||
      order.shippingAddress ||
      order.deliveryAddress,
  );
}

function getStoreAddress(order = {}) {
  return normalizeAddress(order.storeAddress || defaultStoreAddress);
}

async function geocodeAddress(address) {
  const normalizedAddress = normalizeAddress(address);
  if (!normalizedAddress) return null;

  if (!googleMapsApiKey) {
    console.warn(
      JSON.stringify({
        severity: "WARNING",
        service: serviceName,
        event: "maps_geocode_skipped",
        reason: "missing_api_key",
      }),
    );
    return null;
  }

  try {
    const url = new URL("https://maps.googleapis.com/maps/api/geocode/json");
    url.searchParams.set("address", normalizedAddress);
    url.searchParams.set("key", googleMapsApiKey);

    const response = await fetch(url);
    const data = await response.json();

    if (!response.ok || data.status !== "OK" || !data.results?.length) {
      console.warn(
        JSON.stringify({
          severity: "WARNING",
          service: serviceName,
          event: "maps_geocode_failed",
          status: data.status || response.status,
          address: normalizedAddress,
        }),
      );
      return null;
    }

    const location = data.results[0].geometry?.location;
    if (!location) return null;

    return {
      lat: Number(location.lat),
      lng: Number(location.lng),
      formattedAddress: data.results[0].formatted_address || normalizedAddress,
    };
  } catch (error) {
    console.error(
      JSON.stringify({
        severity: "ERROR",
        service: serviceName,
        event: "maps_geocode_error",
        error: error.message,
      }),
    );
    return null;
  }
}

function buildGoogleMapsDirectionsUrl({
  originLat = defaultStoreLat,
  originLng = defaultStoreLng,
  destinationLat,
  destinationLng,
  destinationAddress,
}) {
  const origin = `${originLat},${originLng}`;
  let destination;

  const lat = toNumber(destinationLat);
  const lng = toNumber(destinationLng);
  if (lat !== null && lng !== null) {
    destination = `${lat},${lng}`;
  } else {
    const knownLocation = knownVietnamLocation(destinationAddress);
    destination = knownLocation
      ? `${knownLocation.lat},${knownLocation.lng}`
      : normalizeVietnamAddress(destinationAddress);
  }

  const url = new URL("https://www.google.com/maps/dir/");
  url.searchParams.set("api", "1");
  url.searchParams.set("origin", origin);
  url.searchParams.set("destination", destination);
  url.searchParams.set("travelmode", "two-wheeler");
  return url.toString();
}

async function enrichOrderWithMapData(order, { geocodeMissing = false } = {}) {
  const customerAddress = getCustomerAddress(order);
  const storeAddress = getStoreAddress(order);
  const storeLat = toNumber(order.storeLat) ?? defaultStoreLat;
  const storeLng = toNumber(order.storeLng) ?? defaultStoreLng;
  let customerLat = toNumber(order.customerLat);
  let customerLng = toNumber(order.customerLng);
  let geocoded = false;

  if (
    geocodeMissing &&
    customerAddress &&
    (customerLat === null || customerLng === null)
  ) {
    const knownLocation = knownVietnamLocation(customerAddress);
    const geocode = knownLocation || (await geocodeAddress(customerAddress));
    if (geocode) {
      customerLat = geocode.lat;
      customerLng = geocode.lng;
      geocoded = true;
    }
  }

  const enriched = {
    ...order,
    customerAddress,
    storeAddress,
    storeLat,
    storeLng,
    ...(customerLat !== null ? { customerLat } : {}),
    ...(customerLng !== null ? { customerLng } : {}),
    mapsDirectionsUrl: buildGoogleMapsDirectionsUrl({
      originLat: storeLat,
      originLng: storeLng,
      destinationLat: customerLat,
      destinationLng: customerLng,
      destinationAddress: customerAddress,
    }),
  };

  return { order: enriched, geocoded };
}

module.exports = {
  geocodeAddress,
  buildGoogleMapsDirectionsUrl,
  enrichOrderWithMapData,
};
