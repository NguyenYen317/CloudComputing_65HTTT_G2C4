const express = require("express");
const mapsController = require("../controllers/maps.controller");

const router = express.Router();

router.get("/geocode", mapsController.geocode);
router.get("/directions-url", mapsController.directionsUrl);

module.exports = router;
