import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog/design_system/components/category_chip.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  group('CategoryChip', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CategoryChip(
            label: 'Electronics',
            isSelected: false,
            onTap: () {},
          ),
        ),
      );
      expect(find.text('Electronics'), findsOneWidget);
    });

    testWidgets('shows selected visual state when isSelected is true', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CategoryChip(
            label: 'Clothing',
            isSelected: true,
            onTap: () {},
          ),
        ),
      );

      // Find the AnimatedContainer that represents the chip
      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(containers, isNotEmpty);

      // The selected chip should have primary color background
      final container = containers.first;
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFF2563EB)); // AppColors.primary
    });

    testWidgets('shows unselected visual state when isSelected is false', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CategoryChip(
            label: 'Furniture',
            isSelected: false,
            onTap: () {},
          ),
        ),
      );

      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(containers, isNotEmpty);

      final container = containers.first;
      final decoration = container.decoration as BoxDecoration;
      // Should not be the primary blue color
      expect(decoration.color, isNot(const Color(0xFF2563EB)));
    });

    testWidgets('onTap callback fires when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          CategoryChip(
            label: 'Test',
            isSelected: false,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('selected chip label has white text color', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CategoryChip(
            label: 'Selected',
            isSelected: true,
            onTap: () {},
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Selected'));
      expect(textWidget.style?.color, Colors.white);
    });
  });
}
