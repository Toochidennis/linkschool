import 'package:flutter/material.dart';
import 'dart:math' as math;


class LanyardScreen extends StatelessWidget {
  const LanyardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Interactive Lanyard'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: AnimatedLanyard(),
      ),
    );
  }
}

class AnimatedLanyard extends StatefulWidget {
  const AnimatedLanyard({super.key});

  @override
  State<AnimatedLanyard> createState() => _AnimatedLanyardState();
}

class _AnimatedLanyardState extends State<AnimatedLanyard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _pos = Offset.zero;
  Offset _vel = Offset.zero;
  bool _drag = false;
  Offset? _last;
  DateTime _lastTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 16),
      vsync: this,
    )..repeat();

    _controller.addListener(_tick);
  }

  void _tick() {
    if (!_drag) {
      setState(() {
        const gravity = 0.5;
        const damping = 0.95;
        const spring = 0.02;

        _vel = Offset(
          (_vel.dx + (-_pos.dx * spring)) * damping,
          (_vel.dy + gravity + (-_pos.dy * spring)) * damping,
        );

        _pos += _vel;

        const double maxDist = 150;
        if (_pos.distance > maxDist) {
          _pos = (_pos / _pos.distance) * maxDist;
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start(DragStartDetails d) {
    _drag = true;
    _vel = Offset.zero;
    _last = d.localPosition;
    _lastTime = DateTime.now();
  }

  void _update(DragUpdateDetails d) {
    final now = DateTime.now();
    final dt = now.difference(_lastTime).inMilliseconds / 1000;

    setState(() {
      _pos += d.delta;
      if (_last != null && dt > 0) {
        _vel = (d.localPosition - _last!) / dt * 0.1;
      }
      _last = d.localPosition;
      _lastTime = now;
    });
  }

  void _end(DragEndDetails d) {
    _drag = false;
    _vel *= 0.5;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 600,
      child: CustomPaint(
        painter: _LanyardPainter(offset: _pos),
        child: GestureDetector(
          onPanStart: _start,
          onPanUpdate: _update,
          onPanEnd: _end,
        ),
      ),
    );
  }
}

class _LanyardPainter extends CustomPainter {
  final Offset offset;

  _LanyardPainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final top = Offset(size.width / 2, 50);
    final card = Offset(size.width / 2 + offset.dx, 300 + offset.dy);

    _drawRope(canvas, top, card);
    _drawCard(canvas, card);
    _drawClip(canvas, top);
  }

  void _drawRope(Canvas canvas, Offset start, Offset end) {
    final dist = (end - start).distance;
    final sag = math.min(dist * 0.2, 50);
    
    final mid = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2 + sag,
    );

    final p = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy - 60);

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.grey[400]!, Colors.grey[300]!, Colors.grey[400]!],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromPoints(start, end))
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(p, paint);

    final highlight = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(p, highlight);
  }

  void _drawCard(Canvas canvas, Offset c) {
    const w = 160.0;
    const h = 220.0;
    final rot = offset.dx * 0.002;

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rot);

    final shadow = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(4, 4), width: w, height: h),
      const Radius.circular(12),
    );

    canvas.drawRRect(
      shadow,
      Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    final card = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w, height: h),
      const Radius.circular(12),
    );

    canvas.drawRRect(
      card,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(card.outerRect),
    );

    canvas.drawRRect(
      card,
      Paint()
        ..color = Colors.grey[300]!
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    _drawContent(canvas, w, h);
    _drawCardClip(canvas, Offset(0, -h / 2 + 20));

    canvas.restore();
  }

  void _drawContent(Canvas canvas, double w, double h) {
    canvas.drawCircle(
      Offset(0, -h / 2 + 60),
      25,
      Paint()..color = Colors.blue[700]!,
    );

    final lines = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (var y in [-20.0, 0.0, 20.0]) {
      canvas.drawLine(Offset(-40, y), Offset(40, y), lines);
    }

    final bar = Paint()
      ..color = Colors.grey[800]!
      ..strokeWidth = 2;

    for (var i = 0; i < 15; i++) {
      final x = -35.0 + (i * 5.0);
      canvas.drawLine(Offset(x, h / 2 - 50), Offset(x, h / 2 - 30), bar);
    }
  }

  void _drawCardClip(Canvas canvas, Offset pos) {
    final clip = RRect.fromRectAndRadius(
      Rect.fromCenter(center: pos, width: 30, height: 40),
      const Radius.circular(4),
    );

    canvas.drawRRect(
      clip,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.grey[600]!, Colors.grey[400]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(clip.outerRect),
    );

    canvas.drawCircle(pos, 6, Paint()..color = Colors.grey[800]!);
  }

  void _drawClip(Canvas canvas, Offset pos) {
    canvas.drawCircle(pos, 8, Paint()..color = Colors.grey[700]!..style = PaintingStyle.stroke..strokeWidth = 4);

    final plate = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy - 15), width: 40, height: 15),
      const Radius.circular(3),
    );

    canvas.drawRRect(plate, Paint()..color = Colors.grey[600]!);
  }

  @override
  bool shouldRepaint(_LanyardPainter old) => old.offset != offset;
}