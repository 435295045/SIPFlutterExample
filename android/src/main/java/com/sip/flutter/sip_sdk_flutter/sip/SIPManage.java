package com.sip.flutter.sip_sdk_flutter.sip;

import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;

import com.sip.flutter.sip_sdk_flutter.SipSdkFlutterPlugin;
import com.sip.flutter.sip_sdk_flutter.activity.CallActivity;
import com.sip.flutter.sip_sdk_flutter.activity.entity.CMSIPSDKCallParam;
import com.sip.sdk.SIPSDK;
import com.sip.sdk.entity.SIPSDKCallParam;
import com.sip.sdk.entity.SIPSDKConfig;
import com.sip.sdk.entity.SIPSDKDtmfInfoParam;
import com.sip.sdk.entity.SIPSDKLocalConfig;
import com.sip.sdk.entity.SIPSDKMediaConfig;
import com.sip.sdk.entity.SIPSDKMessageParam;
import com.sip.sdk.entity.SIPSDKRegistrarConfig;
import com.sip.sdk.i.SIPSDKListener;

import java.util.HashMap;
import java.util.Map;

import io.flutter.Log;

public class SIPManage implements SIPSDKListener.InitCompletedListener,
        SIPSDKListener.RegistryStateListener,
        SIPSDKListener.DtmfInfoListener,
        SIPSDKListener.MessageListener,
        SIPSDKListener.MessageStateListener,
        SIPSDKListener.IncomingCallListener,
        SIPSDKListener.CallStateListener,
        SIPSDKListener.ExpireWarningCallbackListener {
    private final Handler handler = new Handler(Looper.getMainLooper());
    private Context context;

    private static class Instance {
        private static final SIPManage instance = new SIPManage();
    }

    public static SIPManage instance() {
        return Instance.instance;
    }

    public void init(Context context,
                     String baseUrl,
                     String clientId,
                     String clientSecret,
                     SIPSDKConfig config,
                     SIPSDKMediaConfig mediaConfig) {
        this.context = context;
        SIPSDK.addListener(this);
        SIPSDK.init(context, baseUrl, clientId, clientSecret, config, mediaConfig);
    }

    @Override
    public void onExpireWarning(long expireTime, long currentTime) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("expireTime", expireTime);
        payload.put("currentTime", currentTime);
        handler.post(() -> {
            SipSdkFlutterPlugin.channel.invokeMethod("onExpireWarning", payload);
        });
    }

    @Override
    public void onRegistryState(int code) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("state", code);
        handler.post(() -> {
            SipSdkFlutterPlugin.channel.invokeMethod("onRegistrarState", payload);
        });
    }

    @Override
    public void onInitCompleted(int state, String msg) {
        Map<String, Object> map = new HashMap<>();
        map.put("state", state);
        map.put("message", msg);
        handler.post(() -> {
            SipSdkFlutterPlugin.channel.invokeMethod("onInitCompleted", map);
        });
    }

    @Override
    public void onIncomingCall(SIPSDKCallParam param) {
        Intent intent = new Intent(this.context, CallActivity.class);
        CMSIPSDKCallParam callParam = new CMSIPSDKCallParam(0, param);
        intent.putExtra("callParam", callParam);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        this.context.startActivity(intent);

        Map<String, Object> payload = new HashMap<>();
        payload.put("callType", callParam.callType);
        payload.put("username", callParam.username);
        payload.put("remoteIp", callParam.remoteIp);
        payload.put("headers", param.headers);
        payload.put("callUUID", String.valueOf(callParam.callUuid));
        payload.put("transmitVideo", callParam.transmitVideo);
        payload.put("transmitSound", callParam.transmitSound);
        handler.post(() -> {
            SipSdkFlutterPlugin.channel.invokeMethod("onIncomingCall", payload);
        });
    }

    @Override
    public void onCallState(long callUuid, int state) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("state", state);
        payload.put("callUUID", String.valueOf(callUuid));
        handler.post(() -> {
            SipSdkFlutterPlugin.channel.invokeMethod("onCallState", payload);
        });
    }

    @Override
    public void onDtmfInfo(SIPSDKDtmfInfoParam param) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("callUUID", String.valueOf(param.callUuid));
        payload.put("dtmfInfoType", param.dtmfInfoType);
        payload.put("contentType", param.contentType);
        payload.put("content", param.content);
        handler.post(() -> {
            SipSdkFlutterPlugin.channel.invokeMethod("onDtmfInfo", payload);
        });
    }

    @Override
    public void onMessage(SIPSDKMessageParam param) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("messageType", param.messageType);
        payload.put("username", param.username);
        payload.put("remoteIp", param.remoteIp);
        payload.put("content", param.content);
        handler.post(() -> {
            SipSdkFlutterPlugin.channel.invokeMethod("onMessage", payload);
        });
    }

    @Override
    public void onMessageState(int state, SIPSDKMessageParam param) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("state", state);
        Map<String, Object> message = new HashMap<>();
        message.put("messageType", param.messageType);
        message.put("username", param.username);
        message.put("remoteIp", param.remoteIp);
        message.put("content", param.content);
        payload.put("message", message);
        handler.post(() -> {
            SipSdkFlutterPlugin.channel.invokeMethod("onMessageState", payload);
        });
    }
}
