import 'dart:io';
import 'package:image/image.dart';

void main() {
  final size = 1024;
  final img = Image(width: size, height: size);
  final center = size ~/ 2;
  final color = ColorRgba8(108, 99, 255, 255);
  final white = ColorRgba8(255, 255, 255, 255);

  final shieldTop = (size * 0.15).toInt();
  final shieldBottom = (size * 0.82).toInt();
  final shieldMidY = (size * 0.68).toInt();
  final shieldHalfW = (size * 0.35).toInt();

  for (int y = shieldTop; y < shieldBottom; y++) {
    for (int x = center - shieldHalfW; x < center + shieldHalfW; x++) {
      double nx = (x - center) / shieldHalfW;
      double ny = (y - shieldTop) / (shieldBottom - shieldTop);

      bool inShield;
      if (y < shieldMidY) {
        double squeeze = 1.0 - ny * 0.05;
        inShield = nx.abs() < squeeze;
      } else {
        double taper = (y - shieldMidY) / (shieldBottom - shieldMidY);
        inShield = nx.abs() < (1.0 - taper * 0.95);
      }

      if (inShield) {
        img.setPixelRgba(x, y, color.r, color.g, color.b, color.a);
      }
    }
  }

  final padTop = (size * 0.5).toInt();
  final bodyTop = (size * 0.4).toInt();
  final bodyBot = (size * 0.62).toInt();
  final halfW = (size * 0.13).toInt();
  final bodyHalfW = (size * 0.18).toInt();
  final sw = (size * 0.028).toInt();

  for (int y = padTop - halfW; y < bodyTop; y++) {
    for (int x = center - halfW; x < center + halfW; x++) {
      int dx = (x - center).abs();
      if (dx > halfW - sw) {
        img.setPixelRgba(x, y, white.r, white.g, white.b, white.a);
      }
    }
  }

  for (int y = bodyTop; y < bodyBot; y++) {
    for (int x = center - bodyHalfW; x < center + bodyHalfW; x++) {
      int dx = (x - center).abs();
      bool isEdge = dx > bodyHalfW - sw || y < bodyTop + sw || y > bodyBot - sw;
      if (isEdge) {
        img.setPixelRgba(x, y, white.r, white.g, white.b, white.a);
      }
    }
  }

  final khY = (size * 0.52).toInt();
  final khR = (size * 0.04).toInt();
  for (int dy = -khR; dy <= khR; dy++) {
    for (int dx = -khR; dx <= khR; dx++) {
      if (dx * dx + dy * dy <= khR * khR) {
        img.setPixelRgba(center + dx, khY + dy, white.r, white.g, white.b, white.a);
      }
    }
  }

  final slW = (size * 0.018).toInt();
  final slH = (size * 0.07).toInt();
  for (int dy = 0; dy < slH; dy++) {
    for (int dx = -slW; dx <= slW; dx++) {
      final py = khY + khR + dy;
      if (py < size) img.setPixelRgba(center + dx, py, white.r, white.g, white.b, white.a);
    }
  }

  File('assets/icon_foreground.png').writeAsBytesSync(encodePng(img));
  print('Done: assets/icon_foreground.png');
}
