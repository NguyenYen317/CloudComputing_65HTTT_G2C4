class MapsConfig {
  const MapsConfig._();

  static const googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static const _defaultStoreLatText = String.fromEnvironment(
    'STORE_LAT',
    defaultValue: '21.028511',
  );

  static const _defaultStoreLngText = String.fromEnvironment(
    'STORE_LNG',
    defaultValue: '105.804817',
  );

  static const defaultStoreAddress = String.fromEnvironment(
    'STORE_ADDRESS',
    defaultValue: 'Ha Noi, Viet Nam',
  );

  static double get defaultStoreLat =>
      double.tryParse(_defaultStoreLatText) ?? 21.028511;

  static double get defaultStoreLng =>
      double.tryParse(_defaultStoreLngText) ?? 105.804817;
}
