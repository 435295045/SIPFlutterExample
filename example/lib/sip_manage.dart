import 'package:flutter/cupertino.dart';
import 'package:sip_sdk_flutter/entitys/sip_sdk_call_param.dart';
import 'package:sip_sdk_flutter/entitys/sip_sdk_config.dart';
import 'package:sip_sdk_flutter/entitys/sip_sdk_dtmf_info.dart';
import 'package:sip_sdk_flutter/entitys/sip_sdk_local_config.dart';
import 'package:sip_sdk_flutter/entitys/sip_sdk_media_config.dart';
import 'package:sip_sdk_flutter/entitys/sip_sdk_message.dart';
import 'package:sip_sdk_flutter/entitys/sip_sdk_registrar_config.dart';
import 'package:sip_sdk_flutter/entitys/sip_sdk_stun_config.dart';
import 'package:sip_sdk_flutter/entitys/sip_sdk_turn_config.dart';
import 'package:sip_sdk_flutter/sip_sdk_callbacks.dart';
import 'package:sip_sdk_flutter/sip_sdk_flutter.dart';

class SIPManage implements SIPSDKCallbacks {
  // 私有构造函数
  SIPManage._internal();

  // 静态私有实例
  static final SIPManage _instance = SIPManage._internal();

  // 工厂构造函数返回单例
  factory SIPManage() => _instance;

  static late SipSdkFlutter _sipSdkFlutterPlugin;

  static void initialize() {
    //初始化插件
    _sipSdkFlutterPlugin = SipSdkFlutter();
    //设置回调
    _sipSdkFlutterPlugin.setupCallbacks(_instance);
    //初始化SDK
    initSDK();
  }

  // 你可以继续在这里写你自己的方法：
  static void initSDK() {
    final config = SIPSDKConfig(
      baseUrl: "https://120.79.7.237",
      clientId: "1379018005584941056",
      clientSecret: "7489ed9e086e12ab45688c0caf4a7d2b",
      userAgent: 'JHCloud-flutter-1.0',
      mediaConfig: SIPSDKMediaConfig(),
      stunConfig: STUNConfig(
        servers: ["120.79.7.237:3478"],
        enableIPv6: false,
      ),
    );
    _sipSdkFlutterPlugin.initSDK(config);
  }

  void registrar() {
    final config = SIPSDKRegistrarConfig(
      domain: "test.com",
      username: "RM-1-1-1-1-1-1",
      password: "123456",
      transport: "tcp",
      serverAddr: "43.160.204.96",
      serverPort: 5060,
      proxy: "43.160.204.96",
      proxyPort: 5060,
      enableStreamControl: false,
      streamElapsed: 0,
      startKeyframeCount: 120,
      startKeyframeInterval: 1000,
      turnConfig: SIPSDKTURNConfig(
        enable: true,
        server: "120.79.7.237:3478",
        realm: "120.79.7.237",
        username: "test",
        password: "test",
      ),
      localConfig: SIPSDKLocalConfig(
        username: "RM-1-1-1-1-1-1",
        enableStreamControl: false,
        streamElapsed: 0,
        startKeyframeCount: 120,
        startKeyframeInterval: 1000,
      ),
    );
    _sipSdkFlutterPlugin.registrar(config);
  }

  void unRegistrar() {
    _sipSdkFlutterPlugin.unRegistrar();
  }

  void call(String username, Map<String, String> headers) {
    _sipSdkFlutterPlugin.call(username, headers);
  }

  void callIP(String ip, Map<String, String> headers) {
    _sipSdkFlutterPlugin.callIP(ip, headers);
  }

  // 通常情况不用调用接听，因为被叫界面是原生代码
  void answer(int code, String callUUID) {
    _sipSdkFlutterPlugin.answer(code, callUUID);
  }

  // 通常情况不用调用发送Dtmf Info，因为被叫界面是原生代码
  void sendDtmfInfo(int type, String content, String callUUID) {
    _sipSdkFlutterPlugin.sendDtmfInfo(type, content, callUUID);
  }

  // 通常情况不用调用挂断，因为被叫界面是原生代码
  void hangup(int code, String callUUID) {
    _sipSdkFlutterPlugin.hangup(code, callUUID);
  }

  void sendMessage(String username, String content) {
    _sipSdkFlutterPlugin.sendMessage(username, content);
  }

  void sendMessageIP(String username, String content) {
    _sipSdkFlutterPlugin.sendMessageIP(username, content);
  }

  // 通常情况不用调用dump，这个主要用于调试
  void dump() {
    _sipSdkFlutterPlugin.dump();
  }

  @override
  void onInitCompleted(int state, String message) {
    debugPrint("onInitCompleted: $state    $message");
    //初始化成功，注册
    if (state == 0) {
      registrar();
    }
  }

  @override
  void onStopCompleted() {
    debugPrint("onStopCompleted");
  }

  @override
  void onRegistrarState(int state) {
    debugPrint("onRegistrarState: $state");
  }

  @override
  void onDtmfInfo(SIPSDKDtmfInfo dtmfInfo) {
    debugPrint("onDtmfInfo: ${dtmfInfo.toString()}");
  }

  @override
  void onMessage(SIPSDKMessage message) {
    debugPrint("onDtmfInfo: ${message.toString()}");
  }

  @override
  void onMessageState(int state, SIPSDKMessage message) {
    debugPrint("onDtmfInfo: $state:${message.toString()}");
  }

  @override
  void onCallState(String callUUID, int state) {
    debugPrint("onCallState: $callUUID:$state");
  }

  @override
  void onIncomingCall(SIPSDKCallParam callParam) {
    debugPrint("onIncomingCall: ${callParam.toString()}");
  }

  @override
  void onExpireWarning(DateTime expireTime, DateTime currentTime) {
    final expireStr = expireTime.toLocal().toString();
    final currentStr = currentTime.toLocal().toString();
    debugPrint(
      'License will expire at: $expireStr, current time is: $currentStr',
    );
  }
}
