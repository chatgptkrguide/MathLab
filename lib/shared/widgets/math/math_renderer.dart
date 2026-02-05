// 📐 Math Renderer Widget
//
// Renders mathematical expressions and equations using LaTeX notation.
// Supports inline math, display math, and automatic size adjustment.

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

/// Math expression renderer with LaTeX support
class MathRenderer extends StatelessWidget {
  /// LaTeX expression to render (e.g., "x^2 + 2x + 1 = 0")
  final String latex;

  /// Display style (true for centered block, false for inline)
  final bool displayMode;

  /// Text style for the math expression
  final TextStyle? textStyle;

  /// Font size multiplier
  final double? fontSize;

  /// Text color
  final Color? color;

  const MathRenderer({
    super.key,
    required this.latex,
    this.displayMode = false,
    this.textStyle,
    this.fontSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final baseStyle = textStyle ?? AppTextStyles.bodyLarge;
      final mathStyle = baseStyle.copyWith(
        color: color ?? AppColors.textPrimary,
        fontSize: fontSize ?? baseStyle.fontSize,
      );

      return Math.tex(
        latex,
        textStyle: mathStyle,
        mathStyle: displayMode ? MathStyle.display : MathStyle.text,
        textScaleFactor: 1.0,
        options: MathOptions(
          fontSize: fontSize ?? 20.0,
          color: color ?? AppColors.textPrimary,
          style: displayMode ? MathStyle.display : MathStyle.text,
        ),
      );
    } catch (e) {
      // Fallback for invalid LaTeX
      return Text(
        latex,
        style: textStyle ?? AppTextStyles.bodyLarge,
      );
    }
  }
}

/// Inline math expression (for use within text)
class InlineMath extends StatelessWidget {
  final String latex;
  final TextStyle? textStyle;
  final double? fontSize;
  final Color? color;

  const InlineMath({
    super.key,
    required this.latex,
    this.textStyle,
    this.fontSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return MathRenderer(
      latex: latex,
      displayMode: false,
      textStyle: textStyle,
      fontSize: fontSize,
      color: color,
    );
  }
}

/// Block/Display math expression (centered, larger)
class DisplayMath extends StatelessWidget {
  final String latex;
  final TextStyle? textStyle;
  final double? fontSize;
  final Color? color;

  const DisplayMath({
    super.key,
    required this.latex,
    this.textStyle,
    this.fontSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: MathRenderer(
          latex: latex,
          displayMode: true,
          textStyle: textStyle,
          fontSize: fontSize ?? 24.0,
          color: color,
        ),
      ),
    );
  }
}

/// Rich text with mixed plain text and math expressions
class MathRichText extends StatelessWidget {
  /// Text with embedded LaTeX in $ delimiters
  /// Example: "Solve for x: $x^2 + 2x + 1 = 0$"
  final String text;
  final TextStyle? textStyle;
  final double? mathFontSize;

  const MathRichText({
    super.key,
    required this.text,
    this.textStyle,
    this.mathFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final parts = _parseTextWithMath(text);
    final baseStyle = textStyle ?? AppTextStyles.bodyLarge;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: parts.map((part) {
        if (part.isMath) {
          return InlineMath(
            latex: part.content,
            textStyle: baseStyle,
            fontSize: mathFontSize,
          );
        } else {
          return Text(part.content, style: baseStyle);
        }
      }).toList(),
    );
  }

  List<_TextPart> _parseTextWithMath(String input) {
    final parts = <_TextPart>[];
    final regex = RegExp(r'\$([^$]+)\$');
    int lastEnd = 0;

    for (final match in regex.allMatches(input)) {
      // Add plain text before math
      if (match.start > lastEnd) {
        parts.add(_TextPart(
          content: input.substring(lastEnd, match.start),
          isMath: false,
        ));
      }

      // Add math expression
      parts.add(_TextPart(
        content: match.group(1)!,
        isMath: true,
      ));

      lastEnd = match.end;
    }

    // Add remaining plain text
    if (lastEnd < input.length) {
      parts.add(_TextPart(
        content: input.substring(lastEnd),
        isMath: false,
      ));
    }

    return parts;
  }
}

class _TextPart {
  final String content;
  final bool isMath;

  _TextPart({required this.content, required this.isMath});
}

/// Predefined common math expressions for quick access
class MathExpressions {
  // Arithmetic
  static const addition = r'a + b';
  static const subtraction = r'a - b';
  static const multiplication = r'a \times b';
  static const division = r'\frac{a}{b}';

  // Algebra
  static const quadratic = r'ax^2 + bx + c = 0';
  static const quadraticFormula = r'x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}';
  static const linear = r'y = mx + b';

  // Geometry
  static const pythagorean = r'a^2 + b^2 = c^2';
  static const circleArea = r'A = \pi r^2';
  static const triangleArea = r'A = \frac{1}{2}bh';

  // Calculus
  static const derivative = r'\frac{d}{dx}f(x)';
  static const integral = r'\int f(x) dx';
  static const limit = r'\lim_{x \to a} f(x)';

  // Statistics
  static const mean = r'\bar{x} = \frac{\sum x_i}{n}';
  static const variance = r'\sigma^2 = \frac{\sum (x_i - \bar{x})^2}{n}';
  static const stdDev = r'\sigma = \sqrt{\frac{\sum (x_i - \bar{x})^2}{n}}';

  // Common symbols
  static const infinity = r'\infty';
  static const pi = r'\pi';
  static const sqrt = r'\sqrt{x}';
  static const fraction = r'\frac{a}{b}';
  static const power = r'x^n';
  static const subscript = r'x_i';
}
