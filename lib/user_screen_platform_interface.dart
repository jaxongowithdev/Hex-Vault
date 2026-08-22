import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'user_screen_method_channel.dart';

abstract class UserScreenPlatform extends PlatformInterface {
  /// Constructs a UserScreenPlatform.
  UserScreenPlatform() : super(token: _token);

  static final Object _token = Object();

  static UserScreenPlatform _instance = MethodChannelUserScreen();

  /// The default instance of [UserScreenPlatform] to use.
  ///
  /// Defaults to [MethodChannelUserScreen].
  static UserScreenPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UserScreenPlatform] when
  /// they register themselves.
  static set instance(UserScreenPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
