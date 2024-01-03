import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ColoredBox(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: Button(),
            ),
          ),
        ),
      ),
    );
  }
}

class Button extends StatefulWidget {
  const Button({super.key});

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  late final _scale = Tween<double>(begin: 1, end: 0.9)
      .chain(CurveTween(curve: Curves.easeInOut))
      .animate(_controller);

  final _fingerprints = ValueNotifier<List<Widget>>([]);

  @override
  void dispose() {
    _controller.dispose();
    _fingerprints.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        _addFingerprint(details.localPosition);
        _controller.forward();
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: _controller.reverse,
      child: ScaleTransition(
        scale: _scale,
        child: ConstrainedBox(
          constraints: const BoxConstraints.tightFor(
            width: 240,
            height: 72,
          ),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Color(0xFF343434),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: ValueListenableBuilder(
                valueListenable: _fingerprints,
                builder: (context, fingerprints, _) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      const Text(
                        'Touch Me',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      ...fingerprints,
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addFingerprint(Offset position) {
    final random = math.Random();
    final opacity = random.nextDouble() * 0.4 + 0.2;
    final angle = random.nextDouble() * 0.7 - 0.35;
    final index = random.nextInt(5);

    final fingerprints = _fingerprints.value;

    _fingerprints.value = List.of(fingerprints)
      ..add(
        Positioned(
          key: ValueKey(fingerprints.length),
          top: position.dy,
          left: position.dx,
          child: FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: Transform.rotate(
              angle: angle,
              child: BackdropFilter(
                filter: ImageFilter.blur(),
                blendMode: BlendMode.lighten,
                child: Image.asset(
                  'assets/fingerprint-$index.png',
                  height: 90,
                  width: 90,
                  opacity: AlwaysStoppedAnimation(opacity),
                ),
              ),
            ),
          ),
        ),
      );
  }
}
