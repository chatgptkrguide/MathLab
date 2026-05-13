/// Number formatting utilities shared across UI widgets.
library;

/// 1,000 이상은 'Nk' 형식(소수점 1자리)으로, 그 외는 그대로 표시.
///
/// 예:
///   - `formatCompact(950)`  -> `'950'`
///   - `formatCompact(1000)` -> `'1k'`
///   - `formatCompact(1500)` -> `'1.5k'`
///   - `formatCompact(2000)` -> `'2k'`
String formatCompact(int number) {
  if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}k'
        .replaceAll('.0k', 'k');
  }
  return number.toString();
}
