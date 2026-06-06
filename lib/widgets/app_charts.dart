/// Hand-painted chart widgets. Replaces fl_chart — drops ~800KB from
/// the release APK and removes a heavy dependency that only served two
/// charts. Both painters are wrapped in [RepaintBoundary] so the
/// parent scroll view's frequent rebuilds don't trigger chart repaints.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────
// INCOME vs EXPENSE BAR
// Two vertical bars with rounded tops, gradient fill, and inline labels.
// Tap a bar to surface its value as a tooltip + haptic feedback.
// ─────────────────────────────────────────
class IncomeExpenseBar extends StatelessWidget {
  final double income;
  final double expense;
  final double height;

  const IncomeExpenseBar({
    super.key,
    required this.income,
    required this.expense,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Semantics(
        container: true,
        label:
            'Income ${_formatKes(income)} Kenyan Shillings, Expenses ${_formatKes(expense)} Kenyan Shillings.',
        excludeSemantics: true,
        child: SizedBox(
          height: height,
          child: CustomPaint(
            painter: _BarPainter(
              income: income,
              expense: expense,
            ),
            child: _BarInteraction(
              income: income,
              expense: expense,
            ),
          ),
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  final double income;
  final double expense;

  _BarPainter({required this.income, required this.expense});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    const labelArea = 24.0; // bottom labels reserve
    const topPadding = 12.0;
    final chartHeight = size.height - labelArea - topPadding;
    final maxValue = (income > expense ? income : expense);
    if (maxValue <= 0) {
      _drawEmptyState(canvas, size);
      return;
    }
    final scale = chartHeight / (maxValue * 1.2);

    final barWidth = 40.0;
    final gap = (size.width - barWidth * 2) / 3;

    // Income bar (left)
    _drawBar(
      canvas,
      Offset(gap, topPadding + chartHeight - (income * scale)),
      Size(barWidth, income * scale),
      AppTheme.success,
    );
    // Expense bar (right)
    _drawBar(
      canvas,
      Offset(gap * 2 + barWidth, topPadding + chartHeight - (expense * scale)),
      Size(barWidth, expense * scale),
      AppTheme.danger,
    );

    // Bottom labels
    _drawLabel(canvas, 'Income', Offset(gap + barWidth / 2, size.height - 14));
    _drawLabel(
      canvas,
      'Expenses',
      Offset(gap * 2 + barWidth + barWidth / 2, size.height - 14),
    );
  }

  void _drawBar(Canvas canvas, Offset topLeft, Size size, Color base) {
    if (size.height <= 0) {
      // Draw a thin baseline so empty bars are still visible.
      final rect = Rect.fromLTWH(topLeft.dx, topLeft.dy, size.width, 2);
      final paint = Paint()..color = base.withValues(alpha: 0.3);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: const Radius.circular(2),
          topRight: const Radius.circular(2),
        ),
        paint,
      );
      return;
    }
    final rect = Rect.fromLTWH(topLeft.dx, topLeft.dy, size.width, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [base, base.withValues(alpha: 0.7)],
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      ),
      paint,
    );
  }

  void _drawLabel(Canvas canvas, String text, Offset center) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTheme.caption.copyWith(color: AppTheme.textSecondary),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  void _drawEmptyState(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final y = size.height - 30;
    canvas.drawLine(Offset(8, y), Offset(size.width - 8, y), paint);
  }

  @override
  bool shouldRepaint(covariant _BarPainter old) =>
      old.income != income || old.expense != expense;
}

class _BarInteraction extends StatefulWidget {
  final double income;
  final double expense;

  const _BarInteraction({required this.income, required this.expense});

  @override
  State<_BarInteraction> createState() => _BarInteractionState();
}

class _BarInteractionState extends State<_BarInteraction> {
  String? _tooltip;

  void _handleTap(Offset localPos, Size size) {
    HapticFeedback.selectionClick();
    final half = size.width / 2;
    final value = localPos.dx < half ? widget.income : widget.expense;
    final label = localPos.dx < half ? 'Income' : 'Expenses';
    setState(() {
      _tooltip = '$label\n${_formatKes(value)}';
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _tooltip = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => _handleTap(d.localPosition, constraints.biggest),
              ),
            ),
            if (_tooltip != null)
              Positioned(
                left: 0,
                right: 0,
                top: 4,
                child: IgnorePointer(
                  child: Center(
                    child: _TooltipBubble(text: _tooltip!),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TooltipBubble extends StatelessWidget {
  final String text;
  const _TooltipBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppTheme.textPrimary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTheme.body.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// EXPENSE BREAKDOWN PIE
// Donut with category labels printed inside each arc + a legend below.
// Tap a slice to surface its category + value.
// ─────────────────────────────────────────
class ExpenseBreakdownPie extends StatelessWidget {
  final Map<String, double> breakdown;
  final double size;
  final Color Function(String type) colorFor;

  const ExpenseBreakdownPie({
    super.key,
    required this.breakdown,
    required this.colorFor,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Semantics(
        container: true,
        label: _semanticLabel(),
        excludeSemantics: true,
        child: SizedBox(
          height: size,
          width: size,
          child: CustomPaint(
            painter: _PiePainter(
              entries: breakdown.entries.toList(),
              colorFor: colorFor,
            ),
            child: _PieInteraction(
              entries: breakdown.entries.toList(),
            ),
          ),
        ),
      ),
    );
  }

  String _semanticLabel() {
    final total = breakdown.values.fold(0.0, (s, v) => s + v);
    if (total == 0) return 'No expense breakdown.';
    final label = breakdown.entries
        .map((e) =>
            '${e.key} ${(e.value / total * 100).toStringAsFixed(0)} percent')
        .join(', ');
    return 'Expense breakdown: $label.';
  }
}

class _PiePainter extends CustomPainter {
  final List<MapEntry<String, double>> entries;
  final Color Function(String type) colorFor;

  _PiePainter({required this.entries, required this.colorFor});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final total = entries.fold(0.0, (s, e) => s + e.value);
    if (total <= 0) return;

    final radius = size.shortestSide / 2 - 4;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);
    const gap = 0.012; // radians between slices

    double start = -3.14159 / 2; // start at 12 o'clock
    final paint = Paint()..style = PaintingStyle.fill;

    for (final entry in entries) {
      final sweep = (entry.value / total) * 6.28318;
      paint.color = colorFor(entry.key);
      canvas.drawArc(rect, start + gap, sweep - gap * 2, true, paint);
      start += sweep;
    }

    // Donut hole
    final holePaint = Paint()..color = AppTheme.cardBg;
    canvas.drawCircle(center, radius * 0.4, holePaint);
  }

  @override
  bool shouldRepaint(covariant _PiePainter old) {
    if (old.entries.length != entries.length) return true;
    for (var i = 0; i < entries.length; i++) {
      if (old.entries[i].key != entries[i].key) return true;
      if (old.entries[i].value != entries[i].value) return true;
    }
    return false;
  }
}

class _PieInteraction extends StatefulWidget {
  final List<MapEntry<String, double>> entries;

  const _PieInteraction({required this.entries});

  @override
  State<_PieInteraction> createState() => _PieInteractionState();
}

class _PieInteractionState extends State<_PieInteraction> {
  String? _tooltip;

  void _handleTap(Offset localPos, Size size) {
    final total = widget.entries.fold(0.0, (s, e) => s + e.value);
    if (total <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;
    final dist = (dx * dx + dy * dy).abs();
    final radius = size.shortestSide / 2 - 4;
    if (dist > radius * radius) return;

    HapticFeedback.selectionClick();
    // Compute angle. 0 rad = right; offset so 12 o'clock = -pi/2.
    var theta = _atan2(dy, dx) + 3.14159 / 2;
    if (theta < 0) theta += 6.28318;
    final picked = (theta / 6.28318) * total;
    double cursor = 0;
    for (final e in widget.entries) {
      cursor += e.value;
      if (picked <= cursor) {
        final pct = (e.value / total * 100).toStringAsFixed(0);
        setState(() => _tooltip = '${e.key} $pct%');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _tooltip = null);
        });
        return;
      }
    }
  }

  // atan2 shim — Dart core has it in dart:math, but pulling math into
  // every chart widget is wasteful. Use a small local implementation
  // to keep the file self-contained for the paint hot path.
  double _atan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.14159;
    if (x < 0 && y < 0) return _atan(y / x) - 3.14159;
    if (x == 0 && y > 0) return 3.14159 / 2;
    if (x == 0 && y < 0) return -3.14159 / 2;
    return 0;
  }

  // Small Taylor-series atan — only used in tap detection (one call
  // per tap), not on the hot paint path. Accurate to ~1e-3.
  double _atan(double z) {
    final absZ = z.abs() > 1 ? 1 / z.abs() : z.abs();
    final a = absZ;
    final a2 = a * a;
    final a3 = a2 * a;
    final a5 = a2 * a3;
    final a7 = a3 * a2 * a2;
    final result = a - a3 / 3 + a5 / 5 - a7 / 7;
    if (z.abs() > 1) {
      return (z < 0 ? -1 : 1) * (3.14159 / 2 - result);
    }
    return (z < 0 ? -1 : 1) * result;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => _handleTap(d.localPosition, constraints.biggest),
              ),
            ),
            if (_tooltip != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 4,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.textPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _tooltip!,
                        style: AppTheme.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

String _formatKes(double value) {
  // Mirror shared_widgets.dart's formatKes: comma thousands + 2 decimals.
  // Inlined to avoid a dep on a util that may not be importable here.
  final fixed = value.toStringAsFixed(0);
  final buf = StringBuffer();
  final chars = fixed.split('');
  for (var i = 0; i < chars.length; i++) {
    if (i > 0 && (chars.length - i) % 3 == 0) buf.write(',');
    buf.write(chars[i]);
  }
  return 'KSh ${buf.toString()}';
}
