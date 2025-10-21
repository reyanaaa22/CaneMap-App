import 'package:flutter/material.dart';

class OnboardingOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback? onComplete;
  final Map<String, GlobalKey>? targetKeys;

  const OnboardingOverlay({
    super.key,
    required this.child,
    this.onComplete,
    this.targetKeys,
  });

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      targetKey: 'plus_button',
      tooltip: 'Click here to register your field.',
      buttonText: 'Next',
      position: TooltipPosition.bottom,
    ),
    OnboardingStep(
      targetKey: 'map_pin',
      tooltip: 'Click the pin to join a field.',
      buttonText: 'Got it',
      position: TooltipPosition.bottom,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_currentStep < _steps.length) _buildOverlay(),
      ],
    );
  }

  Widget _buildOverlay() {
    final currentStepData = _steps[_currentStep];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: () {
          // Allow tapping outside to proceed
          _nextStep();
        },
        child: CustomPaint(
          painter: OnboardingPainter(
            targetKey: widget.targetKeys?[currentStepData.targetKey],
            step: currentStepData,
          ),
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                _buildTooltip(currentStepData),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTooltip(OnboardingStep step) {
    return Positioned(
      bottom: step.position == TooltipPosition.bottom ? 100 : null,
      top: step.position == TooltipPosition.top ? 100 : null,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              step.tooltip,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F8F46),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  step.buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingStep {
  final String targetKey;
  final String tooltip;
  final String buttonText;
  final TooltipPosition position;

  OnboardingStep({
    required this.targetKey,
    required this.tooltip,
    required this.buttonText,
    required this.position,
  });
}

enum TooltipPosition {
  top,
  bottom,
}

class OnboardingPainter extends CustomPainter {
  final GlobalKey? targetKey;
  final OnboardingStep step;

  OnboardingPainter({
    required this.targetKey,
    required this.step,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Fill the entire screen with semi-transparent black
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Cut out the target area
    if (targetKey?.currentContext != null) {
      final RenderBox? renderBox =
          targetKey!.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final targetSize = renderBox.size;

        // Create a slightly larger highlight area
        final highlightRect = Rect.fromLTWH(
          position.dx - 8,
          position.dy - 8,
          targetSize.width + 16,
          targetSize.height + 16,
        );

        // Clear the target area
        final clearPaint = Paint()..blendMode = BlendMode.clear;
        canvas.drawRRect(
          RRect.fromRectAndRadius(highlightRect, const Radius.circular(12)),
          clearPaint,
        );

        // Draw highlight border
        final borderPaint = Paint()
          ..color = const Color(0xFF2F8F46)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

        canvas.drawRRect(
          RRect.fromRectAndRadius(highlightRect, const Radius.circular(12)),
          borderPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
