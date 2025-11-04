import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

/// 수학 수식 텍스트 위젯
/// LaTeX를 수평 분수선을 포함한 수학 표현으로 변환하여 표시
class MathText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final double fontSize;
  final Color? color;

  const MathText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.fontSize = 18,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // LaTeX 분수를 파싱
    final fractions = _parseFractions(text);

    if (fractions.isEmpty) {
      // 분수가 없으면 일반 텍스트로 변환
      final displayText = _convertLatexToUnicode(text);
      return Text(
        displayText,
        style: style ?? AppTextStyles.bodyLarge.copyWith(
          fontSize: fontSize,
          color: color ?? AppColors.textPrimary,
        ),
        textAlign: textAlign,
      );
    }

    // 분수가 있으면 Rich Text로 렌더링
    return _buildMathExpression(context, fractions);
  }

  /// 수학 표현식을 빌드 (분수 포함)
  Widget _buildMathExpression(BuildContext context, List<dynamic> parts) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: parts.map((part) {
        if (part is Map && part['type'] == 'fraction') {
          return _buildFraction(
            part['numerator'] as String,
            part['denominator'] as String,
          );
        } else if (part is String) {
          final converted = _convertLatexToUnicode(part);
          return Text(
            converted,
            style: style ?? AppTextStyles.bodyLarge.copyWith(
              fontSize: fontSize,
              color: color ?? AppColors.textPrimary,
            ),
          );
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }

  /// 수평 분수선을 가진 분수 위젯 생성
  Widget _buildFraction(String numerator, String denominator) {
    final convertedNumerator = _convertLatexToUnicode(numerator);
    final convertedDenominator = _convertLatexToUnicode(denominator);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 분자
          Text(
            convertedNumerator,
            style: style ?? AppTextStyles.bodyLarge.copyWith(
              fontSize: fontSize * 0.8,
              color: color ?? AppColors.textPrimary,
            ),
          ),
          // 분수선
          Container(
            width: _calculateFractionLineWidth(convertedNumerator, convertedDenominator),
            height: 1.5,
            color: color ?? AppColors.textPrimary,
            margin: const EdgeInsets.symmetric(vertical: 1),
          ),
          // 분모
          Text(
            convertedDenominator,
            style: style ?? AppTextStyles.bodyLarge.copyWith(
              fontSize: fontSize * 0.8,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 분수선 너비 계산
  double _calculateFractionLineWidth(String numerator, String denominator) {
    final maxLength = numerator.length > denominator.length
        ? numerator.length
        : denominator.length;
    return (fontSize * 0.6 * maxLength).clamp(20.0, 60.0);
  }

  /// LaTeX 분수를 파싱
  List<dynamic> _parseFractions(String latex) {
    final parts = <dynamic>[];
    final regex = RegExp(r'\\frac\{([^}]+)\}\{([^}]+)\}');
    int lastEnd = 0;

    for (final match in regex.allMatches(latex)) {
      // 분수 앞의 텍스트 추가
      if (match.start > lastEnd) {
        parts.add(latex.substring(lastEnd, match.start));
      }

      // 분수 추가
      parts.add({
        'type': 'fraction',
        'numerator': match.group(1)!,
        'denominator': match.group(2)!,
      });

      lastEnd = match.end;
    }

    // 남은 텍스트 추가
    if (lastEnd < latex.length) {
      parts.add(latex.substring(lastEnd));
    }

    return parts;
  }

  /// LaTeX를 Unicode 수학 기호로 변환
  String _convertLatexToUnicode(String latex) {
    String result = latex;

    // $$...$$제거 (디스플레이 수식)
    result = result.replaceAll(r'$$', '');
    // $...$ 제거 (인라인 수식)
    result = result.replaceAll(r'$', '');

    // 제곱근
    result = result.replaceAll(r'\sqrt[3]', '∛');
    result = result.replaceAll(r'\sqrt[4]', '∜');
    result = result.replaceAll(r'\sqrt[6]', '⁶√');
    result = result.replaceAll(r'\sqrt', '√');

    // 곱하기/나누기
    result = result.replaceAll(r'\times', '×');
    result = result.replaceAll(r'\div', '÷');
    result = result.replaceAll(r'\pm', '±');

    // 비교 연산자
    result = result.replaceAll(r'\neq', '≠');
    result = result.replaceAll(r'\ne', '≠');
    result = result.replaceAll(r'\leq', '≤');
    result = result.replaceAll(r'\geq', '≥');
    result = result.replaceAll(r'\approx', '≈');

    // 괄호
    result = result.replaceAll(r'\left(', '(');
    result = result.replaceAll(r'\right)', ')');
    result = result.replaceAll(r'\left[', '[');
    result = result.replaceAll(r'\right]', ']');
    result = result.replaceAll(r'\{', '{');
    result = result.replaceAll(r'\}', '}');

    // 텍스트 모드
    result = result.replaceAllMapped(
      RegExp(r'\\text\{([^}]+)\}'),
      (match) => match.group(1)!,
    );

    // 지수 표현 ^{-2} → ⁻²
    result = result.replaceAllMapped(
      RegExp(r'\^\{(-?\d+)\}'),
      (match) => _toSuperscript(match.group(1)!),
    );
    result = result.replaceAllMapped(
      RegExp(r'\^(-?\d)'),
      (match) => _toSuperscript(match.group(1)!),
    );

    // 아래첨자 _{2} → ₂
    result = result.replaceAllMapped(
      RegExp(r'_\{(\d+)\}'),
      (match) => _toSubscript(match.group(1)!),
    );
    result = result.replaceAllMapped(
      RegExp(r'_(\d)'),
      (match) => _toSubscript(match.group(1)!),
    );

    // 남은 백슬래시 제거
    result = result.replaceAll(r'\', '');

    return result;
  }

  /// 숫자를 위첨자로 변환
  String _toSuperscript(String number) {
    const superscripts = {
      '0': '⁰',
      '1': '¹',
      '2': '²',
      '3': '³',
      '4': '⁴',
      '5': '⁵',
      '6': '⁶',
      '7': '⁷',
      '8': '⁸',
      '9': '⁹',
      '-': '⁻',
      '+': '⁺',
    };

    return number.split('').map((char) => superscripts[char] ?? char).join('');
  }

  /// 숫자를 아래첨자로 변환
  String _toSubscript(String number) {
    const subscripts = {
      '0': '₀',
      '1': '₁',
      '2': '₂',
      '3': '₃',
      '4': '₄',
      '5': '₅',
      '6': '₆',
      '7': '₇',
      '8': '₈',
      '9': '₉',
    };

    return number.split('').map((char) => subscripts[char] ?? char).join('');
  }
}

/// 인라인 수학 수식 위젯 (작은 크기)
class InlineMath extends StatelessWidget {
  final String expression;
  final double fontSize;
  final Color? color;

  const InlineMath(
    this.expression, {
    super.key,
    this.fontSize = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return MathText(
      expression,
      fontSize: fontSize,
      color: color,
    );
  }
}

/// 블록 수학 수식 위젯 (큰 크기, 중앙 정렬)
class DisplayMath extends StatelessWidget {
  final String expression;
  final double fontSize;
  final Color? color;

  const DisplayMath(
    this.expression, {
    super.key,
    this.fontSize = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MathText(
        expression,
        fontSize: fontSize,
        color: color,
        textAlign: TextAlign.center,
      ),
    );
  }
}
