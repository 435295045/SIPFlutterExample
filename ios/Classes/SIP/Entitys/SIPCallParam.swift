//
//  SIPCallParam.swift
//  SIPSDKExample
//
//  Created by 杨涛 on 2025/5/27.
//
import SIPFramework

struct SIPCallParam {
    let direction: Int
    let callType: Int32
    let username: String?
    let remoteIP: String?
    let headers: [(key: String, value: String)]?
    var callUUID: UInt?
    let transmitVideo: Bool
    let transmitSound: Bool

    // 你可以新增一个自定义初始化器
    init(direction: Int,
         callType: Int32,
         username: String? = nil,
         remoteIP: String? = nil,
         headers: [(key: String, value: String)]? = nil,
         callUUID: UInt? = 0,
         transmitVideo: Bool = true,
         transmitSound: Bool = true)
    {
        self.direction = direction
        self.callType = callType
        self.username = username
        self.remoteIP = remoteIP
        self.headers = headers
        self.callUUID = callUUID
        self.transmitVideo = transmitVideo
        self.transmitSound = transmitSound
    }

    init(cParam: sip_sdk_call_param) {
        direction = 0
        callType = cParam.call_type
        username = cParam.username != nil ? String(cString: cParam.username) : ""
        remoteIP = cParam.remote_ip != nil ? String(cString: cParam.remote_ip) : ""
        callUUID = UInt(cParam.call_uuid)
        transmitVideo = cParam.transmit_video == SDK_TRUE.rawValue ? true : false
        transmitSound = cParam.transmit_sound == SDK_TRUE.rawValue ? true : false
        var headerMap = [(key: String, value: String)]()
        // 使用 withUnsafePointer 获取 headers 指针
        withUnsafePointer(to: cParam.headers) { headersPtr in
            // 将 headers 指针转换为原始字节缓冲区
            let rawPtr = UnsafeRawPointer(headersPtr)
            // 绑定内存为 sip_header 类型
            let buffer = rawPtr.bindMemory(to: sip_header.self, capacity: Int(SDK_MAX_CUSTOM_HEADERS))
            // 遍历数组
            for i in 0 ..< SDK_MAX_CUSTOM_HEADERS {
                let header = buffer[Int(i)]
                if let name = header.key, let value = header.value {
                    headerMap.append((key: String(cString: name), value: String(cString: value)))
                }
            }
        }
        headers = headerMap
    }
}
