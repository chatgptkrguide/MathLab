import 'package:flutter/material.dart';
// TODO: Flutter 3.24.5 호환 수학 렌더링 라이브러리로 교체 필요
// import 'package:flutter_math_fork/flutter_math.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

/// 수학 수식 렌더링 위젯
/// 현재는 Text fallback 사용 (향후 LaTeX 렌더링 추가 예정)
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
    // LaTeX 표현식이 포함되어 있는지 확인
    if (_containsMath(text)) {
      return _buildMathWidget();
    } else {
      // 일반 텍스트
      return Text(
        text,
        style: style ?? AppTextStyles.bodyLarge.copyWith(fontSize: fontSize, color: color),
        textAlign: textAlign,
      );
    }
  }

  bool _containsMath(String text) {
    // LaTeX 기호 또는 한국 수학 기호 감지
    return text.contains(r'\') || // LaTeX 명령어
        text.contains('^') || // 지수
        text.contains('_') || // 아래첨자
        text.contains('∛') || // 세제곱근
        text.contains('∜') || // 네제곱근
        text.contains('√') || // 제곱근
        text.contains('⁶') || // 위첨자
        text.contains('²') ||
        text.contains('³') ||
        text.contains('÷') ||
        text.contains('×');
  }

  Widget _buildMathWidget() {
    // TODO: flutter_math_fork 대신 호환 가능한 수학 렌더링 라이브러리 사용
    // 현재는 일반 텍스트로 표시 (수학 기호는 유니코드로 표시됨)
    return Text(
      text,
      style: style ?? AppTextStyles.bodyLarge.copyWith(fontSize: fontSize, color: color),
      textAlign: textAlign,
    );
  }

  // ignore: unused_element
  String _convertToLatex(String text) {
    String result = text;

    // 한국어 수학 기호를 LaTeX로 변환
    result = result
        // 제곱근
        .replaceAll('√', r'\sqrt')
        .replaceAll('∛', r'\sqrt[3]')
        .replaceAll('∜', r'\sqrt[4]')
        .replaceAll('⁶√', r'\sqrt[6]')

        // 분수 표현 (예: 3/2 → \frac{3}{2})
        // 간단한 분수만 처리
        .replaceAllMapped(
          RegExp(r'(\d+)/(\d+)'),
          (match) => '\\frac{${match.group(1)!}}{${match.group(2)!}}',
        )

        // 지수 표현
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll('⁴', '^4')
        .replaceAll('⁵', '^5')
        .replaceAll('⁶', '^6')

        // 수학 연산자
        .replaceAll('×', r'\times')
        .replaceAll('÷', r'\div')
        .replaceAll('±', r'\pm')
        .replaceAll('≈', r'\approx')
        .replaceAll('≠', r'\neq')
        .replaceAll('≤', r'\leq')
        .replaceAll('≥', r'\geq');

    return result;
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
    // TODO: flutter_math_fork 대신 호환 가능한 수학 렌더링 라이브러리 사용
    return Text(
      expression,
      style: TextStyle(fontSize: fontSize, color: color ?? AppColors.textPrimary),
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
    // TODO: flutter_math_fork 대신 호환 가능한 수학 렌더링 라이브러리 사용
    return Center(
      child: Text(
        expression,
        style: TextStyle(fontSize: fontSize, color: color ?? AppColors.textPrimary),
        textAlign: TextAlign.center,
      ),
    );
  }
}
