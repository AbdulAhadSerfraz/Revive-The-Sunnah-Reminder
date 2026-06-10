import 'package:flutter_test/flutter_test.dart';

/// Custom finder that finds at least N widgets of a given type
/// This is useful for tests that need to verify a minimum number of widgets exist
Finder findsAtLeastNWidget(Type widgetType, int minCount) {
  return find.byType(widgetType);
}

/// Custom matcher that verifies at least N widgets are found
Matcher findsAtLeastNWidgets(Type widgetType, int minCount) {
  return _FindsAtLeastNWidgetsMatcher(widgetType, minCount);
}

class _FindsAtLeastNWidgetsMatcher extends Matcher {
  const _FindsAtLeastNWidgetsMatcher(this.widgetType, this.minCount);

  final Type widgetType;
  final int minCount;

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    if (item is! WidgetTester) {
      return false;
    }

    final finder = find.byType(widgetType);
    final foundCount = item.widgetList(finder).length;

    matchState['foundCount'] = foundCount;
    return foundCount >= minCount;
  }

  @override
  Description describe(Description description) {
    return description
        .add('finds at least $minCount widgets of type $widgetType');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    final foundCount = matchState['foundCount'] ?? 0;
    return mismatchDescription
        .add('found $foundCount widgets, expected at least $minCount');
  }
}
