import 'dart:math';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _mainCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _chartCtrl;

  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;
  late Animation<double> _chartAnim;
  late Animation<double> _textSlideAnim;
  late Animation<double> _taglineAnim;

  @override
  void initState() {
    super.initState();

    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _chartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnim = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(_pulseCtrl);

    _chartAnim = CurvedAnimation(
      parent: _chartCtrl,
      curve: Curves.easeOutCubic,
    );

    _textSlideAnim = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.4, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _taglineAnim = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    );

    _mainCtrl.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _chartCtrl.forward();
    });
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    _chartCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF050210),
              Color(0xFF0D0B2A),
              Color(0xFF130F3A),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background floating particles
            ..._buildParticles(),

            // Main content
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_mainCtrl, _pulseCtrl, _chartCtrl]),
                builder: (context, _) {
                  return Opacity(
                    opacity: _fadeAnim.value.clamp(0.0, 1.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Container with Neon Glow
                        Transform.scale(
                          scale: _scaleAnim.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow ring
                              Container(
                                width: 160 + (_glowAnim.value * 20),
                                height: 160 + (_glowAnim.value * 20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF7F5AF0).withOpacity(0.15 * _glowAnim.value),
                                      blurRadius: 80,
                                      spreadRadius: 30,
                                    ),
                                  ],
                                ),
                              ),
                              // Inner glow
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.transparent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF7F5AF0).withOpacity(0.5 * _glowAnim.value),
                                      blurRadius: 50,
                                      spreadRadius: 10,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF2CB67D).withOpacity(0.3 * _glowAnim.value),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              // Logo background
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF7F5AF0).withOpacity(0.25),
                                      const Color(0xFF2CB67D).withOpacity(0.15),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFF7F5AF0).withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: CustomPaint(
                                    painter: _RisingChartPainter(_chartAnim.value),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // App Name with neon purple glow
                        Transform.translate(
                          offset: Offset(0, _textSlideAnim.value),
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFFFFFFFF),
                                Color(0xFFD4BFFF),
                                Color(0xFF7F5AF0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: Text(
                              'FinModel Pro',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF7F5AF0).withOpacity(_glowAnim.value * 0.9),
                                    blurRadius: 30,
                                  ),
                                  Shadow(
                                    color: const Color(0xFF7F5AF0).withOpacity(_glowAnim.value * 0.5),
                                    blurRadius: 60,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Tagline
                        Opacity(
                          opacity: _taglineAnim.value,
                          child: Column(
                            children: [
                              Text(
                                'Akıllı Finansal Özgürlük',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white.withOpacity(0.55),
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(height: 60),
                              // Animated loading bar
                              SizedBox(
                                width: 180,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: _chartAnim.value,
                                    backgroundColor: Colors.white.withOpacity(0.05),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color.lerp(
                                        const Color(0xFF7F5AF0),
                                        const Color(0xFF2CB67D),
                                        _chartAnim.value,
                                      )!,
                                    ),
                                    minHeight: 3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildParticles() {
    final rand = Random(42);
    return List.generate(12, (i) {
      final x = rand.nextDouble();
      final y = rand.nextDouble();
      final size = rand.nextDouble() * 3 + 1;
      final opacity = rand.nextDouble() * 0.3 + 0.05;
      return Positioned(
        left: x * MediaQuery.of(context).size.width,
        top: y * MediaQuery.of(context).size.height,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(opacity),
          ),
        ),
      );
    });
  }
}

// Custom painter for the rising chart logo
class _RisingChartPainter extends CustomPainter {
  final double progress;
  _RisingChartPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Define bar heights (rising trend)
    final bars = [0.3, 0.45, 0.35, 0.6, 0.5, 0.75, 0.65, 0.9];
    final barWidth = w / (bars.length * 2 - 1);

    for (int i = 0; i < bars.length; i++) {
      final barProgress = ((progress * bars.length) - i).clamp(0.0, 1.0);
      final barH = h * bars[i] * barProgress;
      final x = i * barWidth * 2;
      final y = h - barH;

      final fraction = i / (bars.length - 1);
      final barColor = Color.lerp(
        const Color(0xFF7F5AF0),
        const Color(0xFF2CB67D),
        fraction,
      )!;

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [barColor, barColor.withOpacity(0.4)],
        ).createShader(Rect.fromLTWH(x, y, barWidth, barH))
        ..style = PaintingStyle.fill;

      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, barH),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      );
      canvas.drawRRect(rrect, paint);
    }

    // Draw trend line
    if (progress > 0.5) {
      final linePaint = Paint()
        ..color = Colors.white.withOpacity(0.7 * ((progress - 0.5) * 2))
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      for (int i = 0; i < bars.length; i++) {
        final x = i * barWidth * 2 + barWidth / 2;
        final y = h - h * bars[i];
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, linePaint);

      // Arrow head at the end
      final lastX = (bars.length - 1) * barWidth * 2 + barWidth / 2;
      final lastY = h - h * bars.last;
      final arrowPaint = Paint()
        ..color = const Color(0xFF2CB67D).withOpacity((progress - 0.5) * 2)
        ..style = PaintingStyle.fill;

      final arrowPath = Path()
        ..moveTo(lastX, lastY - 6)
        ..lineTo(lastX - 5, lastY + 2)
        ..lineTo(lastX + 5, lastY + 2)
        ..close();
      canvas.drawPath(arrowPath, arrowPaint);
    }
  }

  @override
  bool shouldRepaint(_RisingChartPainter old) => old.progress != progress;
}
