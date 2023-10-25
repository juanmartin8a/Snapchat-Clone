import 'package:flutter/material.dart';

class TriangleTabIndicator extends Decoration {
  final BoxPainter _painter;

  TriangleTabIndicator({@required Color color, @required double radius}) : _painter = DrawTriangle(color);

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class DrawTriangle extends BoxPainter {
  Paint _paint;

  DrawTriangle(Color color) {
    _paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset triangleOffset = offset + Offset(cfg.size.width / 2, cfg.size.height - 5);
    var path = Path();

    path.moveTo(triangleOffset.dx, triangleOffset.dy);
    path.lineTo(triangleOffset.dx + 5, triangleOffset.dy + 5);
    path.lineTo(triangleOffset.dx - 5, triangleOffset.dy + 5);

    path.close();
    canvas.drawPath(path, _paint);
  }
}
