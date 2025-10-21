import 'package:flutter/material.dart';

class OnboardingTutorial extends StatefulWidget {
  final VoidCallback onComplete;
  final Function(int)? onPageChange;
  const OnboardingTutorial({
    super.key,
    required this.onComplete,
    this.onPageChange,
  });

  @override
  State<OnboardingTutorial> createState() => _OnboardingTutorialState();
}

class _OnboardingTutorialState extends State<OnboardingTutorial> {
  int _currentStep = 0;

  final List<TutorialStep> _steps = [
    TutorialStep(
      title: 'Register Your Field',
      description: 'Click here to register your field.',
      position: TutorialPosition.topRight,
      highlightKey: 'plus_button',
      pageIndex: 0,
    ),
    TutorialStep(
      title: 'View Fields on Map',
      description: 'Click the pin on the map to join a field. Here\'s Ormoc City!',
      position: TutorialPosition.center,
      highlightKey: 'map_section',
      pageIndex: 1,
    ),
    TutorialStep(
      title: 'Apply for Driver Badge',
      description: 'Tap here to apply for a driver badge and unlock driver-specific features.',
      position: TutorialPosition.bottomCenter,
      highlightKey: 'driver_badge_button',
      pageIndex: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _navigateToPage();
  }

  void _navigateToPage() {
    final step = _steps[_currentStep];
    widget.onPageChange?.call(step.pageIndex);
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
        _navigateToPage();
      });
    } else {
      _completeTutorial();
    }
  }

  void _completeTutorial() {
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '🎉 All Set!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2F8F46),
          ),
        ),
        content: const Text(
          "You're all set! Start using CaneMap to explore and manage your fields.",
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F8F46),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onComplete();
            },
            child: const Text(
              'Start Using CaneMap',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return Stack(
      children: [
        // Semi-transparent overlay
        IgnorePointer(
          child: Container(
            color: Colors.black.withOpacity(0.6),
          ),
        ),

        // Tooltip and buttons
        Positioned(
          left: 16,
          right: 16,
          bottom: 100,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${_currentStep + 1} of ${_steps.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F8F46).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${((_currentStep + 1) / _steps.length * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2F8F46),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / _steps.length,
                    minHeight: 4,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF2F8F46),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => _currentStep--);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF2F8F46),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2F8F46),
                            ),
                          ),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F8F46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 4,
                          shadowColor: const Color(0xFF2F8F46).withOpacity(0.3),
                        ),
                        child: Text(
                          _currentStep == _steps.length - 1 ? 'Finish' : 'Next',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TutorialStep {
  final String title;
  final String description;
  final TutorialPosition position;
  final String highlightKey;
  final int pageIndex;

  TutorialStep({
    required this.title,
    required this.description,
    required this.position,
    required this.highlightKey,
    required this.pageIndex,
  });
}

enum TutorialPosition {
  topRight,
  center,
  bottomCenter,
}

