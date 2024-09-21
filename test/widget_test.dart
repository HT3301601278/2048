// 这是一个基本的 Flutter widget 测试。
//
// 要在测试中与 widget 进行交互，请使用 flutter_test 包中的 WidgetTester
// 工具。例如，您可以发送点击和滚动手势。您还可以使用 WidgetTester 在 widget
// 树中查找子 widget，读取文本，并验证 widget 属性的值是否正确。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:helloflutter/main.dart';

void main() {
  testWidgets('计数器增加测试', (WidgetTester tester) async {
    // 构建我们的应用并触发一帧。
    await tester.pumpWidget(MyApp());

    // 验证我们的计数器从0开始。
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // 点击 '+' 图标并触发一帧。
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // 验证我们的计数器已经增加。
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
