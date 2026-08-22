import 'package:flutter_test/flutter_test.dart';
import 'package:user_screen/user_screen.dart';
import 'package:user_screen/user_screen_platform_interface.dart';
import 'package:user_screen/user_screen_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockUserScreenPlatform
    with MockPlatformInterfaceMixin
    implements UserScreenPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final UserScreenPlatform initialPlatform = UserScreenPlatform.instance;

  test('$MethodChannelUserScreen is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelUserScreen>());
  });

  test('getPlatformVersion', () async {
    UserScreen userScreenPlugin = UserScreen();
    MockUserScreenPlatform fakePlatform = MockUserScreenPlatform();
    UserScreenPlatform.instance = fakePlatform;

    expect(await userScreenPlugin.getPlatformVersion(), '42');
  });
}
