package com.sip.flutter.sip_sdk_flutter.activity.entity;

import com.sip.sdk.entity.SIPSDKCallParam;

import java.io.Serializable;
import java.util.Map;

public class CMSIPSDKCallParam implements Serializable {
    // 呼叫方向
    public int direction;
    // 呼叫类型
    public int callType;
    // 呼叫账号
    public String username;
    // 远程IP
    public String remoteIp;
    // SIP headers
    public Map<String, String> headers;
    // 呼叫ID
    public long callUuid;
    // 是否传输视频
    public boolean transmitVideo;
    // 是否传输声音
    public boolean transmitSound;

    public CMSIPSDKCallParam() {
    }

    public CMSIPSDKCallParam(SIPSDKCallParam sdkParam) {
        this.callType = sdkParam.callType;
        this.username = sdkParam.username;
        this.remoteIp = sdkParam.remoteIp;
        this.headers = sdkParam.headers;
        this.callUuid = sdkParam.callUuid;
        this.transmitVideo = sdkParam.transmitVideo;
        this.transmitSound = sdkParam.transmitSound;
    }

    public CMSIPSDKCallParam(int direction, SIPSDKCallParam sdkParam) {
        this.direction = direction;
        this.callType = sdkParam.callType;
        this.username = sdkParam.username;
        this.remoteIp = sdkParam.remoteIp;
        this.headers = sdkParam.headers;
        this.callUuid = sdkParam.callUuid;
        this.transmitVideo = sdkParam.transmitVideo;
        this.transmitSound = sdkParam.transmitSound;
    }

    @Override
    public String toString() {
        return "CMSIPSDKCallParam{" +
                "direction=" + direction +
                ", callType=" + callType +
                ", username='" + username + '\'' +
                ", remoteIp='" + remoteIp + '\'' +
                ", headers=" + headers +
                ", callUuid=" + callUuid +
                ", transmitVideo=" + transmitVideo +
                ", transmitSound=" + transmitSound +
                '}';
    }
}
