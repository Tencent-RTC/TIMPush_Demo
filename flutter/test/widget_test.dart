import 'package:flutter_test/flutter_test.dart';
import 'package:pushdemo/main.dart';

void main() {
  test('parses RegistrationID returned as a plain string', () {
    expect(registrationIdFromPushResultData('test-registration-id'), 'test-registration-id');
  });

  test('parses RegistrationID returned in a map', () {
    expect(registrationIdFromPushResultData({'registrationID': 'test-registration-id'}), 'test-registration-id');
  });

  testWidgets('renders TIMPush Android-aligned demo UI', (tester) async {
    await tester.pumpWidget(const PushDemoApp(autoRegister: false));

    expect(find.text('TIMPush Demo'), findsOneWidget);
    expect(find.text('启动后自动注册，获取推送 ID 用于发送测试'), findsOneWidget);
    expect(find.text('推送 ID'), findsOneWidget);
    expect(find.text('SDKAppID: 0'), findsNothing);
    expect(find.text('复制'), findsOneWidget);
    expect(find.text('刷新'), findsOneWidget);
    expect(find.text('更多操作'), findsOneWidget);
    expect(find.text('自定义推送 ID'), findsOneWidget);
    expect(find.text('重新注册'), findsOneWidget);
    expect(find.text('注销推送'), findsOneWidget);
    expect(find.text('结果'), findsOneWidget);
  });
}
