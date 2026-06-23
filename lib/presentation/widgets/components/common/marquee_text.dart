import 'package:flutter/material.dart';

/// Single-line text that gently auto-scrolls **horizontally** when it overflows
/// its width, instead of truncating with "…".
///
/// Driven by an [AnimationController] (a ticker, not a [Timer]) so it disposes
/// cleanly and leaves no pending timers in widget tests. When the text already
/// fits, it renders a plain [Text] and the animation stays idle.
class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  /// Scroll speed in logical pixels per second (lower = slower).
  final double velocity;

  /// Pause held at each end before reversing.
  final Duration pause;

  const MarqueeText(
    this.text, {
    super.key,
    this.style,
    this.velocity = 26,
    this.pause = const Duration(milliseconds: 1500),
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Configure the cycle length from the overflow amount and (re)start or stop
  /// the ticker. Must run after layout, not during build.
  void _sync(double overflow) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (overflow > 0) {
        final travelMs = (overflow / widget.velocity * 1000).round();
        final total = Duration(
          milliseconds: widget.pause.inMilliseconds * 2 + travelMs * 2,
        );
        if (_controller.duration != total) _controller.duration = total;
        if (!_controller.isAnimating) _controller.repeat();
      } else if (_controller.isAnimating) {
        _controller.stop();
      }
    });
  }

  /// 0 → 1 → 0 with a hold at each end (the hold fraction mirrors [pause]).
  double _progress() {
    final total = _controller.duration?.inMilliseconds ?? 0;
    if (total == 0) return 0;
    final hold = widget.pause.inMilliseconds / total;
    final ramp = 0.5 - hold;
    final t = _controller.value;
    if (t < hold) return 0;
    if (t < 0.5) return (t - hold) / ramp;
    if (t < 0.5 + hold) return 1;
    return 1 - (t - (0.5 + hold)) / ramp;
  }

  @override
  Widget build(BuildContext context) {
    final span = TextSpan(text: widget.text, style: widget.style);
    final dir = Directionality.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tp = TextPainter(text: span, maxLines: 1, textDirection: dir)
          ..layout();
        final overflow = tp.width - constraints.maxWidth;
        _sync(overflow);

        final text = Text(
          widget.text,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
          style: widget.style,
        );
        if (overflow <= 0) return ClipRect(child: text);

        return ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Align(
              alignment: Alignment.centerLeft,
              child: Transform.translate(
                offset: Offset(-_progress() * overflow, 0),
                child: child,
              ),
            ),
            child: text,
          ),
        );
      },
    );
  }
}
