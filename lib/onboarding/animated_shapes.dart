import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackgroundShapes extends StatefulWidget {
  final bool isGreen;
  const AnimatedBackgroundShapes({super.key, this.isGreen = false});

  @override
  State<AnimatedBackgroundShapes> createState() =>
      _AnimatedBackgroundShapesState();
}

class _AnimatedBackgroundShapesState extends State<AnimatedBackgroundShapes>
    with TickerProviderStateMixin {
  late AnimationController _floatingCtrl;
  late AnimationController _rotatingCtrl;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _floatingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _rotatingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingCtrl.dispose();
    _rotatingCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.isGreen
        ? const Color(0xFF1F4B2C).withOpacity(0.38)
        : const Color(0xFF1E6B3A).withOpacity(0.26);
    final accentColor2 = widget.isGreen
        ? const Color(0xFF27653A).withOpacity(0.32)
        : const Color(0xFF3B8D22).withOpacity(0.22);

    return Stack(
      children: [
        // Floating circle top-left
        Positioned(
          top: -40,
          left: -40,
          child: AnimatedBuilder(
            animation: _floatingCtrl,
            builder: (context, _) {
              return Transform.translate(
                offset: Offset(0, _floatingCtrl.value * 60),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor,
                  ),
                ),
              );
            },
          ),
        ),

        // Rotating square top-right
        Positioned(
          top: 60,
          right: -30,
          child: AnimatedBuilder(
            animation: _rotatingCtrl,
            builder: (context, _) {
              return Transform.rotate(
                angle: _rotatingCtrl.value * 2 * math.pi,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: accentColor2,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            },
          ),
        ),

        // Pulsing circle bottom-left
        Positioned(
          bottom: 80,
          left: -50,
          child: AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (context, _) {
              final scale = 0.8 + (_pulseCtrl.value * 0.4);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor,
                  ),
                ),
              );
            },
          ),
        ),

        // Floating triangle bottom-right
        Positioned(
          bottom: -30,
          right: -30,
          child: AnimatedBuilder(
            animation: _floatingCtrl,
            builder: (context, _) {
              return Transform.translate(
                offset: Offset(0, -_floatingCtrl.value * 50),
                child: CustomPaint(
                  painter: TrianglePainter(accentColor2),
                  size: const Size(100, 100),
                ),
              );
            },
          ),
        ),

        // Rotating circle center-right
        Positioned(
          top: 200,
          right: -60,
          child: AnimatedBuilder(
            animation: _rotatingCtrl,
            builder: (context, _) {
              return Transform.rotate(
                angle: _rotatingCtrl.value * 2 * math.pi,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor,
                      width: 3,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) => false;
}

class AnimatedPageTransition extends StatefulWidget {
  final Widget child;
  final int pageIndex;

  const AnimatedPageTransition({
    super.key,
    required this.child,
    required this.pageIndex,
  });

  @override
  State<AnimatedPageTransition> createState() => _AnimatedPageTransitionState();
}

class _AnimatedPageTransitionState extends State<AnimatedPageTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedPageTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageIndex != widget.pageIndex) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
