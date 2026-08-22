import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'user_screen_platform_interface.dart';

/// An implementation of [UserScreenPlatform] that uses method channels.
class MethodChannelUserScreen extends UserScreenPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('user_screen');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
