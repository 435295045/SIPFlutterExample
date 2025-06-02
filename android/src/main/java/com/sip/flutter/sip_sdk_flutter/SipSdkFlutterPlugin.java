package com.sip.flutter.sip_sdk_flutter;

import static com.sip.sdk.entity.SDKConstants.SDK_CALL_TYPE_IP;
import static com.sip.sdk.entity.SDKConstants.SDK_CALL_TYPE_SERVER;
import static com.sip.sdk.entity.SDKConstants.SDK_DTMF_INFO_TYPE;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;

import androidx.annotation.NonNull;

import com.sip.flutter.sip_sdk_flutter.activity.CallActivity;
import com.sip.flutter.sip_sdk_flutter.activity.entity.CMSIPSDKCallParam;
import com.sip.flutter.sip_sdk_flutter.sip.SIPManage;
import com.sip.flutter.sip_sdk_flutter.utils.MapUtils;
import com.sip.sdk.SIPSDK;
import com.sip.sdk.entity.SIPSDKConfig;
import com.sip.sdk.entity.SIPSDKLocalConfig;
import com.sip.sdk.entity.SIPSDKMediaConfig;
import com.sip.sdk.entity.SIPSDKMediaH264Fmtp;
import com.sip.sdk.entity.SIPSDKRegistrarConfig;
import com.sip.sdk.entity.SIPSDKStunConfig;
import com.sip.sdk.entity.SIPSDKTurnConfig;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * SipSdkFlutterPlugin
 */
public class SipSdkFlutterPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    public static MethodChannel channel;

    @SuppressLint("StaticFieldLeak")
    public static Context context;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "sip_sdk_flutter");
        channel.setMethodCallHandler(this);
        SipSdkFlutterPlugin.context = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("initSDK")) {
            initSDK(call.arguments(), result);
        } else if (call.method.equals("registrar")) {
            registrar(call.arguments(), result);
        } else if (call.method.equals("unRegistrar")) {
            unRegistrar(call.arguments(), result);
        } else if (call.method.equals("call")) {
            call(call.arguments(), result);
        } else if (call.method.equals("callIP")) {
            callIP(call.arguments(), result);
        } else if (call.method.equals("answer")) {
            answer(call.arguments(), result);
        } else if (call.method.equals("sendDtmfInfo")) {
            sendDtmfInfo(call.arguments(), result);
        } else if (call.method.equals("sendMessage")) {
            sendMessage(call.arguments(), result);
        } else if (call.method.equals("sendMessageIP")) {
            sendMessageIP(call.arguments(), result);
        } else if (call.method.equals("hangup")) {
            hangup(call.arguments(), result);
        } else if (call.method.equals("dump")) {
            dump(call.arguments(), result);
        } else if (call.method.equals("destroy")) {
            destroy(call.arguments(), result);
        } else if (call.method.equals("handleIpChange")) {
            handleIpChange(call.arguments(), result);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    private void initSDK(Map<String, Object> args, MethodChannel.Result result) {
        Map<String, Object> stunDict = MapUtils.getMap(args, "stunConfig");
        SIPSDKStunConfig stunConfig = null;
        if (stunDict != null) {
            List<String> servers = MapUtils.get(stunDict, "servers", new ArrayList<>());
            boolean enableIPv6 = MapUtils.get(stunDict, "enableIPv6", false);
            stunConfig = new SIPSDKStunConfig();
            stunConfig.count = servers.size();
            stunConfig.servers = servers;
            stunConfig.enableIpv6 = enableIPv6;
        }

        Map<String, Object> mediaDict = MapUtils.getMap(args, "mediaConfig");
        SIPSDKMediaConfig mediaConfig = new SIPSDKMediaConfig();
        if (mediaDict != null) {
            mediaConfig.audioClockRate = MapUtils.get(mediaDict, "audioClockRate", 16000);
            mediaConfig.micGain = MapUtils.get(mediaDict, "micGain", 1.0f);
            mediaConfig.speakerGain = MapUtils.get(mediaDict, "speakerGain", 1.0f);
            mediaConfig.nsEnable = MapUtils.get(mediaDict, "nsEnable", true);
            mediaConfig.agcEnable = MapUtils.get(mediaDict, "agcEnable", true);
            mediaConfig.aecEnable = MapUtils.get(mediaDict, "aecEnable", true);
            mediaConfig.aecEliminationTime = MapUtils.get(mediaDict, "aecEliminationTime", (short) 30);
            mediaConfig.notEnableEncode = MapUtils.get(mediaDict, "notEnableEncode", false);
            mediaConfig.notEnableDecode = MapUtils.get(mediaDict, "notEnableDecode", false);
            mediaConfig.decodeMaxWidth = MapUtils.get(mediaDict, "decodeMaxWidth", 1920);
            mediaConfig.decodeMaxHeight = MapUtils.get(mediaDict, "decodeMaxHeight", 1080);
            mediaConfig.combinSpsPpsIdr = MapUtils.get(mediaDict, "combinSpsPpsIdr", false);
            String profileLevelId = MapUtils.get(mediaDict, "profileLevelId", null);
            String packetizationMode = MapUtils.get(mediaDict, "packetizationMode", null);
            if (profileLevelId != null && !profileLevelId.isEmpty() && packetizationMode != null && !packetizationMode.isEmpty()) {
                if (mediaConfig.h264Fmtp == null) {
                    mediaConfig.h264Fmtp = new SIPSDKMediaH264Fmtp();
                }
                mediaConfig.h264Fmtp.profileLevelId = profileLevelId;
                mediaConfig.h264Fmtp.packetizationMode = packetizationMode;
            }
        }

        SIPSDKConfig config = new SIPSDKConfig();
        config.port = MapUtils.get(args, "port", 58581);
        config.logLevel = MapUtils.get(args, "logLevel", 4);
        config.userAgent = MapUtils.get(args, "userAgent", "");
        config.workerThreadCount = MapUtils.get(args, "workerThreadCount", 1);
        config.videoEnable = MapUtils.get(args, "enableVideo", true);
        config.videoOutAutoTransmit = MapUtils.get(args, "videoOutAutoTransmit", true);
        config.allowMultipleConnections = MapUtils.get(args, "allowMultipleConnections", false);
        config.domainNameDirectRegistrar = MapUtils.get(args, "domainNameDirectRegistrar", false);
        config.doesItSupportBroadcast = MapUtils.get(args, "doesItSupportBroadcast", false);
        config.stunConfig = stunConfig;
        String baseUrl = MapUtils.get(args, "baseUrl", "");
        String clientId = MapUtils.get(args, "clientId", "");
        String clientSecret = MapUtils.get(args, "clientSecret", "");
        SIPManage.instance().init(context, baseUrl, clientId, clientSecret, config, mediaConfig);
        result.success(null);
    }

    private void registrar(Map<String, Object> args, MethodChannel.Result result) {
        Map<String, Object> localDict = MapUtils.getMap(args, "localConfig");
        SIPSDKLocalConfig localConfig = null;
        if (localDict != null) {
            localConfig = new SIPSDKLocalConfig();
            localConfig.username = MapUtils.get(localDict, "username", null);
            localConfig.proxy = MapUtils.get(localDict, "proxy", null);
            localConfig.proxyPort = MapUtils.get(localDict, "proxyPort", 0);
            localConfig.enableStreamControl = MapUtils.get(localDict, "enableStreamControl", false);
            localConfig.streamElapsed = MapUtils.get(localDict, "streamElapsed", 0);
            localConfig.startKeyframeCount = MapUtils.get(localDict, "startKeyframeCount", 120);
            localConfig.startKeyframeInterval = MapUtils.get(localDict, "startKeyframeInterval", 1000);
        }

        Map<String, Object> turnDict = MapUtils.getMap(args, "turnConfig");
        SIPSDKTurnConfig turnConfig = null;
        if (turnDict != null) {
            turnConfig = new SIPSDKTurnConfig();
            turnConfig.enable = MapUtils.get(turnDict, "enable", false);
            turnConfig.server = MapUtils.get(turnDict, "server", null);
            turnConfig.realm = MapUtils.get(turnDict, "realm", null);
            turnConfig.username = MapUtils.get(turnDict, "username", null);
            turnConfig.password = MapUtils.get(turnDict, "password", null);
        }

        Map<String, String> headers = new HashMap<>();
        Map<String, Object> rawHeaders = MapUtils.getMap(args, "headers");
        if (rawHeaders != null) {
            for (Map.Entry<String, Object> entry : rawHeaders.entrySet()) {
                if (entry.getValue() instanceof String) {
                    headers.put(entry.getKey(), (String) entry.getValue());
                }
            }
        }

        SIPSDKRegistrarConfig config = new SIPSDKRegistrarConfig();
        config.domain = MapUtils.get(args, "domain", null);
        config.username = MapUtils.get(args, "username", null);
        config.password = MapUtils.get(args, "password", null);
        config.transport = MapUtils.get(args, "transport", null);
        config.serverAddr = MapUtils.get(args, "serverAddr", null);
        config.serverPort = MapUtils.get(args, "serverPort", 5060);
        config.proxy = MapUtils.get(args, "proxy", null);
        config.proxyPort = MapUtils.get(args, "proxyPort", 5060);
        config.enableStreamControl = MapUtils.get(args, "enableStreamControl", false);
        config.streamElapsed = MapUtils.get(args, "streamElapsed", 0);
        config.startKeyframeCount = MapUtils.get(args, "startKeyframeCount", 120);
        config.startKeyframeInterval = MapUtils.get(args, "startKeyframeInterval", 1000);
        config.headers = headers;
        config.turnConfig = turnConfig;

        SIPSDK.registrarAccount(config);
        result.success(null);
    }

    /**
     * 解除注册到服务器
     */
    private void unRegistrar(Map<String, Object> args, MethodChannel.Result result) {
        SIPSDK.unRegistrar();
        result.success(null);
    }

    private void call(Map<String, Object> args, MethodChannel.Result result) {
        String username = MapUtils.get(args, "username", null);
        Map<String, String> headers = new HashMap<>();
        Map<String, Object> rawHeaders = MapUtils.getMap(args, "headers");
        if (rawHeaders != null) {
            for (Map.Entry<String, Object> entry : rawHeaders.entrySet()) {
                if (entry.getValue() instanceof String) {
                    headers.put(entry.getKey(), (String) entry.getValue());
                }
            }
        }

        CMSIPSDKCallParam callParam = new CMSIPSDKCallParam();
        callParam.direction = 1;
        callParam.callType = SDK_CALL_TYPE_SERVER;
        callParam.username = username;
        callParam.headers = new HashMap<>();

        Intent intent = new Intent(context, CallActivity.class);
        intent.putExtra("callParam", callParam);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);

        result.success(null);
    }

    private void callIP(Map<String, Object> args, MethodChannel.Result result) {
        String ip = MapUtils.get(args, "ip", null);
        Map<String, String> headers = new HashMap<>();
        Map<String, Object> rawHeaders = MapUtils.getMap(args, "headers");
        if (rawHeaders != null) {
            for (Map.Entry<String, Object> entry : rawHeaders.entrySet()) {
                if (entry.getValue() instanceof String) {
                    headers.put(entry.getKey(), (String) entry.getValue());
                }
            }
        }
        CMSIPSDKCallParam callParam = new CMSIPSDKCallParam();
        callParam.direction = 1;
        callParam.callType = SDK_CALL_TYPE_IP;
        callParam.remoteIp = ip;
        callParam.headers = new HashMap<>();

        Intent intent = new Intent(context, CallActivity.class);
        intent.putExtra("callParam", callParam);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);

        result.success(null);
    }

    private void answer(Map<String, Object> args, MethodChannel.Result result) {
        int code = MapUtils.get(args, "200", 200);
        long callUUID = MapUtils.get(args, "callUUID", 0);
        SIPSDK.answer(code, callUUID);
        result.success(null);
    }

    private void sendDtmfInfo(Map<String, Object> args, MethodChannel.Result result) {
        long callUUID = MapUtils.get(args, "callUUID", 0);
        int dtmfInfoType = MapUtils.get(args, "dtmfInfoType", SDK_DTMF_INFO_TYPE);
        String content = MapUtils.get(args, "content", null);
        String contentType = MapUtils.get(args, "contentType", null);
        SIPSDK.sendDtmfInfo(dtmfInfoType, contentType, content);
        result.success(null);
    }

    private void sendMessage(Map<String, Object> args, MethodChannel.Result result) {
        String username = MapUtils.get(args, "username", null);
        String content = MapUtils.get(args, "content", null);
        SIPSDK.sendMessage(username, content);
        result.success(null);
    }

    private void sendMessageIP(Map<String, Object> args, MethodChannel.Result result) {
        String ip = MapUtils.get(args, "ip", null);
        String content = MapUtils.get(args, "content", null);
        SIPSDK.sendMessageIP(ip, content);
        result.success(null);
    }

    private void hangup(Map<String, Object> args, MethodChannel.Result result) {
        int code = MapUtils.get(args, "code", 487);
        long callUUID = MapUtils.get(args, "callUUID", 0);
        if (callUUID == 0) {
            SIPSDK.hangup(code);
        } else {
            SIPSDK.hangupWithUuid(code, callUUID);
        }
        result.success(null);
    }

    /**
     * 打印SDK信息，包括所有内存使用信息
     */
    private void dump(Map<String, Object> args, MethodChannel.Result result) {
        SIPSDK.dump();
        result.success(null);
    }

    private void destroy(Map<String, Object> args, MethodChannel.Result result) {
        SIPSDK.destroy();
        result.success(null);
    }

    private void handleIpChange(Map<String, Object> args, MethodChannel.Result result) {
        SIPSDK.handleIpChange();
        result.success(null);
    }
}
