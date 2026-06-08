class ImageHelper {
  ImageHelper._();

  static String withUnsplashParams(String image) {
    if (image.isEmpty || image.contains('?')) return image;
    return '$image?auto=format&fit=crop&w=500&q=80';
  }

  static bool isNetworkImage(String image) {
    return image.startsWith('http://') || image.startsWith('https://');
  }
}
