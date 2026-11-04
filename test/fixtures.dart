import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Ảnh JPEG [width]×[height], tùy chọn có EXIF xoay và GPS.
Uint8List jpegBytes(
  int width,
  int height, {
  int? orientation,
  double? gpsLatitude,
}) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(200, 120, 40));
  if (orientation != null) image.exif.imageIfd.orientation = orientation;
  if (gpsLatitude != null) {
    image.exif.gpsIfd
      ..gpsLatitudeRef = 'N'
      ..gpsLatitude = gpsLatitude;
  }
  return img.encodeJpg(image);
}
