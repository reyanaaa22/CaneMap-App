import 'package:flutter/material.dart';
import 'dart:math' as math;
// simplified imports; no external particles

import '../onboarding/onboarding_flow.dart';

class SplashFlow extends StatefulWidget {
  const SplashFlow({super.key});

  @override
  State<SplashFlow> createState() => _SplashFlowState();
}

class _SplashFlowState extends State<SplashFlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );
  // Circle drop from top (y offset factor: -0.40 -> 0)
  late final Animation<double> _circleDrop =
      Tween<double>(begin: -0.40, end: 0.0).animate(
    CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(0.00, 0.30, curve: Curves.easeOutCubic),
    ),
  );
  // Circle scale from tiny (2%) to full cover - continuous smooth expansion
  late final Animation<double> _circleScale = Tween<double>(begin: 0.02, end: 1.0).animate(
    CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(0.10, 0.60, curve: Curves.easeInOutCubic),
    ),
  );
  // Circle opacity to avoid popping
  late final Animation<double> _circleOpacity = CurvedAnimation(
    parent: _introCtrl,
    curve: const Interval(0.05, 0.15, curve: Curves.easeIn),
  );

  @override
  void initState() {
    super.initState();
    // Brief pure-white hold before any green appears
    Future.delayed(const Duration(milliseconds: 280), () {
      if (mounted) _introCtrl.forward();
    });
    // Remove auto-navigation; onboarding opens only via Get started button
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF2F8F46);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background stays white until the circle fully covers the screen,
            // then snaps to green (circle is what performs the transition)
            AnimatedBuilder(
              animation: _introCtrl,
              builder: (context, _) {
                final fullyCovered = _circleScale.value >= 0.995;
                return Container(color: fullyCovered ? green : Colors.white);
              },
            ),
            // Circle: very small, drops from top, bounces at center, then expands to cover
            AnimatedBuilder(
              animation: _introCtrl,
              builder: (context, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final sizePx = constraints.biggest;
                    // Use diagonal so circle can cover the screen completely
                    final diagonal = math.sqrt(
                      sizePx.width * sizePx.width +
                          sizePx.height * sizePx.height,
                    );
                    final coverDiameter = diagonal + 40; // small buffer
                    final scale = _circleScale.value;
                    final size = coverDiameter * scale;
                    final dropFactor = _circleDrop.value; // -0.40 .. 0.0
                    final dy = constraints.biggest.height * dropFactor;
                    return Transform.translate(
                      offset: Offset(0, dy),
                      child: Center(
                        child: Opacity(
                          opacity: _circleOpacity.value,
                          child: Container(
                            width: size,
                            height: size,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2F8F46),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            // Logo + text appear after circle fully covers screen
            AnimatedBuilder(
              animation: _introCtrl,
              builder: (context, _) {
                final t = _introCtrl.value;
                final active = t > 0.55;
                // Hold centered, then gently move upward a bit before showing sheet
                final rawUp = ((t - 0.70) / 0.10).clamp(0.0, 1.0);
                final slideUp = Curves.easeOut.transform(rawUp);
                final dy = -96.0 * slideUp;
                return Center(
                  child: Opacity(
                    opacity: active ? 1 : 0,
                    child: Transform.translate(
                      offset: Offset(0, dy),
                      child: _LogoBrandTransition(active: active),
                    ),
                  ),
                );
              },
            ),

            // Stage 3 — Bottom white curved container with welcome, description, CTA, dots
            AnimatedBuilder(
              animation: _introCtrl,
              builder: (context, _) {
                // Delay the rise further; user sees logo/text longer before sheet enters
                final t = _introCtrl.value;
                // Start the sheet after logo has begun moving upward
                final raw = ((t - 0.80) / 0.20).clamp(0.0, 1.0);
                final slide = Curves.fastOutSlowIn.transform(raw);
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform.translate(
                    offset: Offset(0, (1.0 - slide) * 240),
                    child: Opacity(
                      opacity: slide,
                      child: _BottomSheetWelcome(),
                    ),
                  ),
                );
              },
            ),

            // Removed old pager footer; intro is a single sequence now
          ],
        ),
      ),
    );
  }
}

// Home entry was previously used to lazily resolve the home route. Navigation
// is now handled directly (OnboardingFlow or named '/home').

// _AnimatedLogo removed — simplified splash uses _LogoBrandTransition directly.

// (previous _LogoWithTitle removed — replaced by _LogoBrandTransition)

/// Logo + Brand transition widget: scales the logo, slides it left and fades/slides in brand text.
class _LogoBrandTransition extends StatefulWidget {
  final bool active;
  const _LogoBrandTransition({required this.active});

  @override
  State<_LogoBrandTransition> createState() => _LogoBrandTransitionState();
}

class _LogoBrandTransitionState extends State<_LogoBrandTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late final Animation<double> _scale = Tween(
    begin: 0.45,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  // Logo stays centered first, then slides left to make room for text
  late final Animation<Offset> _logoSlide =
      Tween(begin: Offset.zero, end: const Offset(-0.12, 0)).animate(
    CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
    ),
  );
  late final Animation<double> _textFade = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.70, 1.0, curve: Curves.easeIn),
  );
  late final Animation<Offset> _textSlide =
      Tween(begin: const Offset(0.16, 0), end: Offset.zero).animate(
    CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.70, 1.0, curve: Curves.easeOutCubic),
    ),
  );

  @override
  void didUpdateWidget(covariant _LogoBrandTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_ctrl.isAnimating && _ctrl.value == 0.0) {
      _ctrl.forward();
    } else if (!widget.active && _ctrl.value > 0.0) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlideTransition(
                  position: _logoSlide,
                  child: ScaleTransition(
                    scale: _scale,
                    child: const _LogoWithAccent(size: 110),
                  ),
                ),
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Transform.translate(
                      offset: const Offset(-12, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [_StaggeredTitle()],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// (removed unused _FadeInText — replaced by explicit transitions in _LogoBrandTransition)

// _WelcomeCard removed — simplified splash directly transitions to onboarding.

class _LogoIcon extends StatelessWidget {
  final double size;
  const _LogoIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    // Try to load an optional asset; if not present, build a composed icon.
    try {
      return Image.asset('assets/images/logo.png', width: size, height: size);
    } catch (_) {
      return _PulsingLogo(size: size);
    }
  }
}

class _LogoWithAccent extends StatefulWidget {
  final double size;
  const _LogoWithAccent({required this.size});

  @override
  State<_LogoWithAccent> createState() => _LogoWithAccentState();
}

class _LogoWithAccentState extends State<_LogoWithAccent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final Animation<double> _scale = Tween(
    begin: 0.9,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _bounce, curve: Curves.elasticOut));

  @override
  void initState() {
    super.initState();
    _bounce.forward();
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Soft halo instead of external particle asset
        Container(
          width: size * 1.1,
          height: size * 1.1,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0x7C, 0xCF, 0x00, 0.25),
                blurRadius: 24,
                spreadRadius: 6,
              ),
            ],
          ),
        ),
        ScaleTransition(
          scale: _scale,
          child: _LogoIcon(size: size),
        ),
      ],
    );
  }
}

class _PulsingLogo extends StatefulWidget {
  final double size;
  const _PulsingLogo({required this.size});

  @override
  State<_PulsingLogo> createState() => _PulsingLogoState();
}

class _PulsingLogoState extends State<_PulsingLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);
  late final Animation<double> _halo = Tween(
    begin: 0.0,
    end: 10.0,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Container(
          width: size + _halo.value,
          height: size + _halo.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7CCF00), Color(0xFF2F8F46)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0x7C, 0xCF, 0x00, 0.35),
                blurRadius: 18 + _halo.value,
                spreadRadius: 2 + _halo.value * 0.4,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.eco_rounded, size: size * 0.6, color: Colors.white),
              Positioned(
                bottom: size * 0.16,
                right: size * 0.2,
                child: Icon(
                  Icons.agriculture,
                  size: size * 0.28,
                  color: Colors.white.withAlpha((0.9 * 255).round()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StaggeredTitle extends StatefulWidget {
  const _StaggeredTitle();
  @override
  State<_StaggeredTitle> createState() => _StaggeredTitleState();
}

class _StaggeredTitleState extends State<_StaggeredTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeIn,
  );
  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0.06, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: const Text(
          'CaneMap',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _StaggeredSubtitle extends StatefulWidget {
  const _StaggeredSubtitle();
  @override
  State<_StaggeredSubtitle> createState() => _StaggeredSubtitleState();
}

class _StaggeredSubtitleState extends State<_StaggeredSubtitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
  );
  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0.08, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 250), () => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: const Text(
          'Sugarcane mapping and harvest planning',
          style: TextStyle(fontSize: 13, color: Colors.white70),
        ),
      ),
    );
  }
}

class _BottomSheetWelcome extends StatefulWidget {
  const _BottomSheetWelcome();

  @override
  State<_BottomSheetWelcome> createState() => _BottomSheetWelcomeState();
}

class _BottomSheetWelcomeState extends State<_BottomSheetWelcome>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loadingCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _loadingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF2F8F46);
    return Container(
      height: 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Welcome to CaneMap',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Smart sugarcane field mapping and harvest planning',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 4,
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const OnboardingFlow()),
                );
              },
              child: const Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLoadingIndicator(green),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(Color color) {
    return AnimatedBuilder(
      animation: _loadingCtrl,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.15;
            final progress = (_loadingCtrl.value + delay) % 1.0;
            final opacity = (math.sin(progress * math.pi) * 0.5 + 0.5).clamp(0.3, 1.0);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Simple transition wrapper that fades and slides a page based on active index.
// old page transition removed: intro is single-stage now
