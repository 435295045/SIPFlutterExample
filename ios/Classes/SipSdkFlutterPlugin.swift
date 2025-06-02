import Flutter
import SIPFramework
import UIKit

public class SipSdkFlutterPlugin: NSObject, FlutterPlugin {
    static var channel: FlutterMethodChannel?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "sip_sdk_flutter", binaryMessenger: registrar.messenger())
        let instance = SipSdkFlutterPlugin()
        SipSdkFlutterPlugin.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initSDK":
            if let args = call.arguments as? [String: Any] {
                initSDK(args: args, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected dictionary", details: nil))
            }
        case "registrar":
            if let args = call.arguments as? [String: Any] {
                registrar(args: args, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected dictionary", details: nil))
            }
        case "unRegistrar":
            if let args = call.arguments as? [String: Any] {
                unRegistrar(args: args, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected dictionary", details: nil))
            }
        case "call":
            if let args = call.arguments as? [String: Any] {
                self.call(args: args, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected dictionary", details: nil))
            }
        case "callIP":
            if let args = call.arguments as? [String: Any] {
                callIP(args: args, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected dictionary", details: nil))
            }
        case "answer":
            if let args = call.arguments as? [String: Any] {
                answer(args: args, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected dictionary", details: nil))
            }
        case "sendDtmfInfo":
            if let args = call.arguments as? [String: Any] {
                sendDtmfInfo(args: args, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected dictionary", details: nil))
            }
        case "sendMessage":
            if let args = call.arguments as? [String: Any] {
                sendMessage(args: args, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected dictionary", details: nil))
            }
        case "sendMessageIP":
            if let args = call.arguments as? [String: Any] {
                sendMessageIP(args: args, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected dictionary", details: nil))
            }
        case "hangup":
            if let args = call.arguments as? [String: Any] {
                hangup(args: args, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected dictionary", details: nil))
            }
        case "dump":
            if let args = call.arguments as? [String: Any] {
                dump(args: args, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected dictionary", details: nil))
            }
        case "handleIpChange":
            if let args = call.arguments as? [String: Any] {
                handleIpChange(args: args, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected dictionary", details: nil))
            }
        case "destroy":
            if let args = call.arguments as? [String: Any] {
                destroy(args: args, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected dictionary", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func initSDK(args: [String: Any], result: @escaping FlutterResult) {
        // 1. 提取 stunConfig
        var stun: STUNConfig? = nil
        if let stunDict = args["stunConfig"] as? [String: Any] {
            let servers = (stunDict["servers"] as? [String]) ?? []
            let enableIPv6 = (stunDict["enableIPv6"] as? Bool) ?? false
            stun = STUNConfig(servers: servers, enableIPv6: enableIPv6)
        }

        // 2. 提取 mediaConfig（可选，如果你有用到）
        var mediaConfig: SIPSDKMediaConfig? = nil
        if let mediaDict = args["mediaConfig"] as? [String: Any] {
            mediaConfig = SIPSDKMediaConfig(
                audioClockRate: Int32(mediaDict["audioClockRate"] as? Int ?? 16000),
                micGain: (mediaDict["micGain"] as? NSNumber)?.floatValue ?? 1.0,
                speakerGain: (mediaDict["speakerGain"] as? NSNumber)?.floatValue ?? 1.0,
                nsEnable: (mediaDict["nsEnable"] as? Bool) ?? true,
                agcEnable: (mediaDict["agcEnable"] as? Bool) ?? true,
                aecEnable: (mediaDict["aecEnable"] as? Bool) ?? true,
                aecEliminationTime: Int16(mediaDict["aecEliminationTime"] as? Int ?? 30),
                notEnableEncode: (mediaDict["notEnableEncode"] as? Bool) ?? false,
                notEnableDecode: (mediaDict["notEnableDecode"] as? Bool) ?? false,
                decodeMaxWidth: UInt32(mediaDict["decodeMaxWidth"] as? Int ?? 1920),
                decodeMaxHeight: UInt32(mediaDict["decodeMaxHeight"] as? Int ?? 1080),
                combinSpsPpsIdr: (mediaDict["combinSpsPpsIdr"] as? Bool) ?? false,
                profileLevelId: mediaDict["profileLevelId"] as? String,
                packetizationMode: mediaDict["packetizationMode"] as? String
            )
        } else {
            mediaConfig = SIPSDKMediaConfig()
        }

        // 配置回调
        let callbacks = SIPSDKCallbacks(
            onLogCallback: SIPManage.onLogCallback,
            onInitCompleted: SIPManage.onInitCompleted,
            onStopCompleted: SIPManage.onStopCompleted,
            onRegistrarState: SIPManage.onRegistrarState,
            onIncomingCall: SIPManage.onIncomingCall,
            onDtmfInfo: SIPManage.onDtmfInfo,
            onMessage: SIPManage.onMessage,
            onMessageState: SIPManage.onMessageState,
            onCallState: SIPManage.onCallState,
            onExpireWarning: SIPManage.onExpireWarning
        )

        // 3. 提取 SIPSDKConfig 主结构体字段
        let config = SIPSDKConfig(
            port: UInt32(args["port"] as? Int ?? 58581),
            publicAddr: args["publicAddr"] as? String,
            logLevel: Int32(args["logLevel"] as? Int ?? 4),
            userAgent: args["userAgent"] as? String ?? "",
            workerThreadCount: Int32(args["workerThreadCount"] as? Int ?? 1),
            enableVideo: (args["enableVideo"] as? Bool) ?? true,
            sdkObserver: callbacks,
            allowMultipleConnections: (args["allowMultipleConnections"] as? Bool) ?? false,
            domainNameDirectRegistrar: (args["domainNameDirectRegistrar"] as? Bool) ?? false,
            doesItSupportBroadcast: (args["doesItSupportBroadcast"] as? Bool) ?? false,
            stunConfig: stun
        )
        let baseUrl: String = args["baseUrl"] as? String ?? ""
        let clientId: String = args["clientId"] as? String ?? ""
        let clientSecret: String = args["clientSecret"] as? String ?? ""
        SIPHandle.initSDK(baseUrl: baseUrl,
                          clientId: clientId,
                          clientSecret: clientSecret,
                          config: config,
                          mediaConfig: mediaConfig!)
        result(nil) // 表示成功
    }

    private func registrar(args: [String: Any], result: @escaping FlutterResult) {
        var localConfig: REGLocalConfig?
        if let localConfigDict = args["localConfig"] as? [String: Any] {
            let username = localConfigDict["username"] as? String
            let proxy = localConfigDict["proxy"] as? String
            let proxyPort = UInt32(localConfigDict["proxyPort"] as? Int ?? 0)
            let enableStreamControl = (localConfigDict["enableStreamControl"] as? Bool) ?? false
            let streamElapsed = Int32(localConfigDict["streamElapsed"] as? Int ?? 0)
            let startKeyframeCount = UInt32(localConfigDict["startKeyframeCount"] as? Int ?? 120)
            let startKeyframeInterval = UInt32(localConfigDict["startKeyframeInterval"] as? Int ?? 1000)

            localConfig = REGLocalConfig(
                username: username,
                proxy: proxy,
                proxyPort: proxyPort,
                enableStreamControl: enableStreamControl,
                streamElapsed: streamElapsed,
                startKeyframeCount: startKeyframeCount,
                startKeyframeInterval: startKeyframeInterval
            )
        }

        var turnConfig: TURNConfig?
        if let turnConfigDict = args["turnConfig"] as? [String: Any] {
            let enable = (turnConfigDict["enable"] as? Bool) ?? false
            let server = turnConfigDict["server"] as? String
            let realm = turnConfigDict["realm"] as? String
            let username = turnConfigDict["username"] as? String
            let password = turnConfigDict["password"] as? String

            turnConfig = TURNConfig(
                enable: enable,
                server: server,
                realm: realm,
                username: username,
                password: password
            )
        }

        let headers = (args["headers"] as? [String: String])?.map { ($0.key, $0.value) }

        let domain = args["domain"] as? String
        let username = args["username"] as? String
        let password = args["password"] as? String
        let transport = args["transport"] as? String
        let serverAddr = args["serverAddr"] as? String
        let serverPort = UInt32(args["serverPort"] as? Int ?? 5060)
        let proxy = args["proxy"] as? String
        let proxyPort = UInt32(args["proxyPort"] as? Int ?? 0)
        let enableStreamControl = (args["enableStreamControl"] as? Bool) ?? false
        let streamElapsed = Int32(args["streamElapsed"] as? Int ?? 0)
        let startKeyframeCount = UInt32(args["startKeyframeCount"] as? Int ?? 120)
        let startKeyframeInterval = UInt32(args["startKeyframeInterval"] as? Int ?? 1000)

        let config = REGConfig(
            domain: domain,
            username: username,
            password: password,
            transport: transport,
            serverAddr: serverAddr,
            serverPort: serverPort,
            headers: headers,
            proxy: proxy,
            proxyPort: proxyPort,
            enableStreamControl: enableStreamControl,
            streamElapsed: streamElapsed,
            startKeyframeCount: startKeyframeCount,
            startKeyframeInterval: startKeyframeInterval,
            turnConfig: turnConfig
        )

        // 这里调用你自己的注册接口，确保 localConfig 不为空时才调用
        if let localConfig = localConfig {
            SIPHandle.registrar(localConfig: localConfig, config: config)
        } else {
            print("localConfig is nil, cannot registrar")
        }
        result(nil) // 表示成功
    }

    /**
     * 解除注册到服务器
     */
    private func unRegistrar(args _: [String: Any], result: @escaping FlutterResult) {
        SIPHandle.unRegistrar()
        result(nil)
    }

    /**
     * 通过服务器呼叫
     * username: 对方用户名
     * headers: 自定义头信息
     */
    private func call(args: [String: Any], result: @escaping FlutterResult) {
        let username = args["username"] as? String
        let headers = (args["headers"] as? [String: String])?.map { ($0.key, $0.value) }
        let sipCallParam = SIPCallParam(direction: 1,
                                        callType: SDK_MESSAGE_TYPE_SERVER.rawValue,
                                        username: username,
                                        headers: headers)
        DispatchQueue.main.async {
            let callVC = CallViewController(callParam: sipCallParam)
            NavigationCoordinator.shared.present(callVC)
        }
        result(nil)
    }

    /**
     * 通过服IP呼叫
     * ip: 对方IP
     * headers: 自定义头信息
     */
    private func callIP(args: [String: Any], result: @escaping FlutterResult) {
        let ip = args["ip"] as? String
        let headers = (args["headers"] as? [String: String])?.map { ($0.key, $0.value) }
        let sipCallParam = SIPCallParam(direction: 1,
                                        callType: SDK_MESSAGE_TYPE_IP.rawValue,
                                        remoteIP: ip,
                                        headers: headers)
        DispatchQueue.main.async {
            let callVC = CallViewController(callParam: sipCallParam)
            NavigationCoordinator.shared.present(callVC)
        }
        result(nil)
    }

    /**
     * 接听呼叫
     * code: 接听状态码，正常接听200，先通媒体183
     * callUuid: 接听所有0，接听指定呼叫不等于0
     */
    private func answer(args: [String: Any], result: @escaping FlutterResult) {
        let code = UInt32(args["code"] as? Int ?? 200)
        let callUUID = UInt(args["callUUID"] as? Int ?? 0)
        SIPHandle.answer(code: code, callUuid: callUUID)
        result(nil)
    }

    /**
     * 发送info消息
     * type: 消息类型
     * contentType: 内容类型
     * content: 内容（除自定义类型外、其他的类型内容只能是一个字节）
     * callUuid: 为0所有呼叫发送，不等于0指定呼叫发送
     */
    private func sendDtmfInfo(args: [String: Any], result: @escaping FlutterResult) {
        let dtmfInfoType = Int32(args["dtmfInfoType"] as? Int ?? 0)
        let content = args["content"] as? String ?? ""
        let callUUID = UInt(args["callUUID"] as? Int ?? 0)
        // 发送
        SIPHandle.sendDtmfInfo(type: dtmfInfoType, callUuid: callUUID, content: content)
        // 成功回调
        result(nil)
    }

    /**
     * 通过服务器发送sip message消息
     * username: 对方账号
     * content: 内容
     */
    private func sendMessage(args: [String: Any], result: @escaping FlutterResult) {
        let username = args["username"] as? String ?? ""
        let content = args["content"] as? String ?? ""
        // 发送
        SIPHandle.sendMessage(username: username, content: content)
        // 成功回调
        result(nil)
    }

    /**
     * 通过IP发送sip message消息
     * username: 对方账号
     * content: 内容
     */
    private func sendMessageIP(args: [String: Any], result: @escaping FlutterResult) {
        let ip = args["ip"] as? String ?? ""
        let content = args["content"] as? String ?? ""
        // 发送
        SIPHandle.sendMessageIP(ip: ip, content: content)
        // 成功回调
        result(nil)
    }

    /**
     * 挂断 call_uuid 对应的呼叫
     * code: 挂断状态码，正常挂断200
     * callUuid: 为0挂断所有呼叫，不等于0挂断指定呼叫
     */
    private func hangup(args: [String: Any], result: @escaping FlutterResult) {
        let code = UInt32(args["code"] as? Int ?? 200)
        let callUUID = UInt(args["callUUID"] as? Int ?? 0)
        SIPHandle.hangup(code: code, callUuid: callUUID)
        result(nil)
    }

    /**
     *  打印SDK信息，包括所有内存使用信息
     */
    private func dump(args _: [String: Any], result: @escaping FlutterResult) {
        SIPHandle.dump()
        result(nil)
    }

    /**
     *  IP 发生改变调用
     */
    private func handleIpChange(args _: [String: Any], result: @escaping FlutterResult) {
        SIPHandle.handleIpChange()
        result(nil)
    }

    /**
     *  销毁
     */
    private func destroy(args _: [String: Any], result: @escaping FlutterResult) {
        SIPHandle.destroy()
        result(nil)
    }
}
