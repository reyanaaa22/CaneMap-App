import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../splash/widgets/dots.dart';
import '../auth/auth_flow.dart';
import 'animated_shapes.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<_OnboardPageData> _pages = const [
    _OnboardPageData(
      title: 'Track Your Sugarcane Fields',
      subtitle:
          'View, monitor, and update your fields in real-time using the interactive map.',
      imageAsset: 'assets/images/Onboarding 1.png',
      backgroundGreen: false,
    ),
    _OnboardPageData(
      title: 'Submit Reports Without the Paperwork',
      subtitle:
          'No more scattered messages. CaneMap organizes field updates, photo logs, and validation reports — all in one place.',
      imageAsset: 'assets/images/Onboarding 2.png',
      backgroundGreen: false,
    ),
    _OnboardPageData(
      title: 'Custom Dashboards per Role',
      subtitle:
          'Landowners, Farmers, MFOs, and Admins each get personalized access to features relevant to their work.',
      imageAsset: 'assets/images/Onboarding 3.png',
      backgroundGreen: false,
    ),
    _OnboardPageData(
      title: 'Estimate Harvest with Confidence',
      subtitle:
          'Estimate and plan harvests using field summaries, sensor inputs, and historical yields.',
      imageAsset: 'assets/images/Onboarding 4.png',
      backgroundGreen: false,
    ),
    _OnboardPageData(
      title: 'Visual Mapping by Barangay and Field',
      subtitle:
          'Easily visualize fields and map work by area for faster coordination and better decisions.',
      imageAsset: 'assets/images/Onboarding 5.png',
      backgroundGreen: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final p = (_controller.page ?? 0).round();
      if (p != _index) setState(() => _index = p);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goHome() {
    // After onboarding, open the Sign In page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeChoicePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGreen = _pages[_index].backgroundGreen;
    return Scaffold(
      backgroundColor: isGreen ? const Color(0xFF62A96B) : Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              itemBuilder: (context, i) {
                final page = _pages[i];
                return _OnboardPage(data: page, pageIndex: i);
              },
            ),
            Positioned(
              right: 16,
              top: 8,
              child: TextButton(
                onPressed: _goHome,
                style: TextButton.styleFrom(
                  foregroundColor: isGreen ? Colors.white : const Color(0xFF2F8F46),
                ),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: isGreen ? Colors.white : const Color(0xFF2F8F46),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 32,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DotsIndicator(count: _pages.length, index: _index),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F8F46),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: const Color(0xFF2F8F46).withOpacity(0.5),
                        ),
                        onPressed: () {
                          if (_index < _pages.length - 1) {
                            _controller.animateToPage(
                              _index + 1,
                              duration: const Duration(milliseconds: 420),
                              curve: Curves.easeOut,
                            );
                          } else {
                            _goHome();
                          }
                        },
                        child: Text(
                          _index < _pages.length - 1 ? 'Next' : 'Get Started',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPageData {
  final String title;
  final String subtitle;
  final String? imageAsset;
  final bool backgroundGreen;
  const _OnboardPageData({
    required this.title,
    required this.subtitle,
    this.imageAsset,
    required this.backgroundGreen,
  });
}

class _OnboardPage extends StatelessWidget {
  final _OnboardPageData data;
  final int pageIndex;
  const _OnboardPage({required this.data, this.pageIndex = 0});

  @override
  Widget build(BuildContext context) {
    final isGreen = data.backgroundGreen;
    final titleColor = const Color(0xFF2F5E1F);
    final subtitleColor = Color.fromRGBO(0x31, 0x5D, 0x2B, 0.85);
    
    return Container(
      color: isGreen ? const Color(0xFF62A96B) : Colors.white,
      child: Stack(
        children: [
          AnimatedBackgroundShapes(isGreen: isGreen),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 120),
                AnimatedPageTransition(
                  pageIndex: pageIndex,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: isGreen ? Colors.white : titleColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Center(
                    child: data.imageAsset != null
                        ? Image.asset(
                            data.imageAsset!,
                            fit: BoxFit.contain,
                            width: 320,
                            height: 320,
                          )
                        : _OnboardLottie(
                            url:
                                'https://lottie.host/96d03853-13ae-407b-8bc6-e6f78f8420b7/kyZx1zxJqy.lottie',
                            speed: 3.0,
                            backgroundGreen: isGreen,
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedPageTransition(
                  pageIndex: pageIndex,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      data.subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: isGreen ? Colors.white70 : subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardLottie extends StatefulWidget {
  final String url;
  final double speed;
  final bool backgroundGreen;

  const _OnboardLottie({
    required this.url,
    this.speed = 1.0,
    this.backgroundGreen = false,
  });

  @override
  State<_OnboardLottie> createState() => _OnboardLottieState();
}

class _OnboardLottieState extends State<_OnboardLottie>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color:
              widget.backgroundGreen ? Colors.white : const Color(0xFFe7f6ec),
          child: Lottie.network(
            widget.url,
            // Use a controller when we can safely create one from the loaded
            // composition so we can control playback speed. If we can't, fall
            // back to the built-in autoplay/repeat behavior.
            controller: _ctrl,
            onLoaded: (composition) {
              // Guarded: composition may be invalid or throw during parsing.
              try {
                // If composition.duration is available, create an AnimationController
                // whose duration is composition.duration / speed so playback runs
                // `speed` times faster.
                final compDuration = composition.duration;
                if (compDuration.inMilliseconds > 0) {
                  // Dispose any previous controller before creating a new one.
                  _ctrl?.dispose();
                  _ctrl = AnimationController(
                    vsync: this,
                    duration: Duration(
                      milliseconds:
                          (compDuration.inMilliseconds / widget.speed).round(),
                    ),
                  )..repeat();

                  // Rebuild so the Lottie widget picks up the controller.
                  if (mounted) setState(() {});
                }
              } catch (e) {
                // If anything goes wrong (including parser asserts), leave
                // controller null so Lottie falls back to animate/repeat; the
                // errorBuilder will render on fatal parse errors.
              }
            },
            // If we have a controller, Lottie uses it; otherwise allow built-in anim.
            repeat: _ctrl == null,
            animate: _ctrl == null,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.white,
              child: const Center(
                child: Icon(Icons.cloud_off, color: Colors.redAccent, size: 42),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
