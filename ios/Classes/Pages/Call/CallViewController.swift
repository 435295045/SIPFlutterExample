//
//  CallViewController.swift
//  SIPSDKExample
//
//  Created by 杨涛 on 2025/5/25.
//
import AVFoundation
import SIPFramework
import UIKit

class CallViewController: UIViewController {
    var videoContainerView: UIView!
    private var videoLayer: AVSampleBufferDisplayLayer?

    private let controlContainer = UIView()
    private var topStackView: UIStackView!
    private var bottomStackView: UIStackView!

    private var callParam: SIPCallParam

    private var buttonMute: (button: UIButton, label: UILabel, stack: UIStackView)!
    private var buttonSpeak: (button: UIButton, label: UILabel, stack: UIStackView)!
    private var buttonCamera: (button: UIButton, label: UILabel, stack: UIStackView)!
    private var buttonSwitchCamera: (button: UIButton, label: UILabel, stack: UIStackView)!
    private var buttonUnlock: (button: UIButton, label: UILabel, stack: UIStackView)!
    private var buttonAnswer: (button: UIButton, label: UILabel, stack: UIStackView)!
    private var buttonHangup: (button: UIButton, label: UILabel, stack: UIStackView)!

    private var isControlsVisible = true

    init(callParam: SIPCallParam) {
        self.callParam = callParam
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 黑色背景
        view.backgroundColor = .black

        setupVideoView()
        setupControls()

        let tap = UITapGestureRecognizer(
            target: self, action: #selector(toggleControls)
        )
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cameraStateChangeReady(_:)),
            name: .CAMERA_STATE_CHANGE,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleVideoLayerReady(_:)),
            name: .VIDEO_LAYER_READY,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sipCallStateReady(_:)),
            name: .SIP_CALL_STATE_CHANGE,
            object: nil
        )
    }

    private func setupVideoView() {
        videoContainerView = UIView(frame: view.bounds)
        videoContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(videoContainerView)

        controlContainer.frame = view.bounds
        controlContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(controlContainer)
    }

    private func setupControls() {
        topStackView = UIStackView()
        topStackView.axis = .horizontal
        topStackView.distribution = .equalSpacing
        topStackView.alignment = .center
        topStackView.translatesAutoresizingMaskIntoConstraints = false

        bottomStackView = UIStackView()
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .equalSpacing
        bottomStackView.alignment = .center
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false

        controlContainer.addSubview(topStackView)
        controlContainer.addSubview(bottomStackView)

        NSLayoutConstraint.activate([
            topStackView.leadingAnchor.constraint(
                equalTo: controlContainer.leadingAnchor, constant: 24
            ),
            topStackView.trailingAnchor.constraint(
                equalTo: controlContainer.trailingAnchor, constant: -24
            ),
            topStackView.bottomAnchor.constraint(
                equalTo: controlContainer.bottomAnchor, constant: -130
            ),

            bottomStackView.leadingAnchor.constraint(
                equalTo: controlContainer.leadingAnchor, constant: 24
            ),
            bottomStackView.trailingAnchor.constraint(
                equalTo: controlContainer.trailingAnchor, constant: -24
            ),
            bottomStackView.bottomAnchor.constraint(
                equalTo: controlContainer.bottomAnchor, constant: -20
            ),
        ])

        // 静音
        buttonMute = makeRoundIconWithLabel(systemImage: "mic.slash.fill", title: "静音")
        topStackView.addArrangedSubview(buttonMute!.stack)
        // 免提
        buttonSpeak = makeRoundIconWithLabel(systemImage: "speaker.wave.2.fill", title: "免提")
        topStackView.addArrangedSubview(buttonSpeak!.stack)
        // 摄像头
        buttonCamera = makeRoundIconWithLabel(systemImage: "video.fill", title: "摄像头")
        topStackView.addArrangedSubview(buttonCamera!.stack)

        // 切换摄像头
        buttonSwitchCamera = makeRoundIconWithLabel(systemImage: "camera.rotate.fill", title: "切换摄像头")
        bottomStackView.addArrangedSubview(buttonSwitchCamera!.stack)
        if callParam.direction == 0 {
            // 接听
            buttonAnswer = makeRoundIconWithLabel(systemImage: "phone.fill.arrow.up.right", title: "接听", bgColor: .systemGreen)
            bottomStackView.addArrangedSubview(buttonAnswer!.stack)
        } else {
            if callParam.callType == SDK_MESSAGE_TYPE_SERVER.rawValue {
                callParam.callUUID = SIPHandle.call(username: callParam.username!, headers: callParam.headers)
            } else {
                callParam.callUUID = SIPHandle.callIP(ip: callParam.remoteIP!, headers: callParam.headers)
            }
        }
        // 挂断
        buttonHangup = makeRoundIconWithLabel(systemImage: "phone.down.fill", title: "挂断", bgColor: .systemRed)
        bottomStackView.addArrangedSubview(buttonHangup!.stack)
        // 开锁
        buttonUnlock = makeRoundIconWithLabel(systemImage: "lock.open.fill", title: "开锁")
        bottomStackView.addArrangedSubview(buttonUnlock!.stack)

        // 切换状态
        stateSwitch()
    }

    private func makeRoundIconWithLabel(systemImage: String, title: String, bgColor: UIColor = .clear) -> (UIButton, UILabel, UIStackView) {
        let button = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: systemImage), for: .normal)
        } else {
            // fallback image from assets
            button.setImage(UIImage(named: systemImage), for: .normal)
        }
        button.tintColor = .white
        button.backgroundColor = bgColor

        if bgColor == .clear {
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.borderWidth = 1
        }

        button.layer.cornerRadius = 32
        button.clipsToBounds = true
        button.widthAnchor.constraint(equalToConstant: 64).isActive = true
        button.heightAnchor.constraint(equalToConstant: 64).isActive = true
        button.addTarget(self, action: #selector(handleButtonTapped(_:)), for: .touchUpInside)

        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .center
        label.heightAnchor.constraint(equalToConstant: 18).isActive = true

        let stack = makeVerticalStack(button: button, label: label)

        return (button: button, label: label, stack: stack)
    }

    private func makeVerticalStack(button: UIButton, label: UILabel) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [button, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }

    // 检测状态
    private func stateSwitch() {
        let isSpeak = PCMPlayer.instance.speakerEnabled()
        if isSpeak {
            buttonSpeak!.button.tintColor = .black
            buttonSpeak!.button.backgroundColor = .white
        } else {
            buttonSpeak!.button.tintColor = .white
            buttonSpeak!.button.backgroundColor = .clear
        }
        let isMute = PCMRecorder.instance.muteEnabled()
        if isMute {
            buttonMute!.button.tintColor = .black
            buttonMute!.button.backgroundColor = .white
        } else {
            buttonMute!.button.tintColor = .white
            buttonMute!.button.backgroundColor = .clear
        }
    }

    @objc private func toggleControls() {
        isControlsVisible.toggle()
        controlContainer.isHidden = !isControlsVisible
    }

    @objc private func handleButtonTapped(_ button: UIButton) {
        // 移除接听按钮及其 label 所在的 stack
        if button == buttonMute!.button {
            let isMute = PCMRecorder.instance.muteEnabled()
            PCMRecorder.instance.setMute(enabled: !isMute)
            stateSwitch()
        } else if button == buttonSpeak!.button {
            let isSpeak = PCMPlayer.instance.speakerEnabled()
            PCMPlayer.instance.setSpeaker(enabled: !isSpeak)
            stateSwitch()
        } else if button == buttonCamera!.button {
            let isCameraRunning = CameraCaptureManager.shared.isRunning
            if isCameraRunning {
                CameraCaptureManager.shared.stop()
            } else {
                CameraCaptureManager.shared.start()
            }
            stateSwitch()
        } else if button == buttonSwitchCamera!.button {
            CameraCaptureManager.shared.switchCamera()
        } else if button == buttonHangup!.button {
            SIPHandle.hangup(code: 487, callUuid: 0)
            dismiss(animated: true)
        } else if button == buttonUnlock!.button {
        } else if button == buttonAnswer!.button {
            bottomStackView.removeArrangedSubview(buttonAnswer!.stack)
            buttonAnswer!.stack.removeFromSuperview()
            SIPHandle.answer(code: 200, callUuid: callParam.callUUID!)
        }
    }

    @objc private func cameraStateChangeReady(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let isRunning = userInfo["isRunning"] as? Bool else { return }
        DispatchQueue.main.async {
            if isRunning {
                self.buttonCamera!.button.tintColor = .black
                self.buttonCamera!.button.backgroundColor = .white
            } else {
                self.buttonCamera!.button.tintColor = .white
                self.buttonCamera!.button.backgroundColor = .clear
            }
        }
    }

    @objc private func handleVideoLayerReady(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let layer = userInfo["layer"] as? AVSampleBufferDisplayLayer else { return }

        videoLayer = layer
        DispatchQueue.main.async {
            layer.frame = self.videoContainerView.bounds
            layer.videoGravity = .resizeAspect
            self.videoContainerView.layer.addSublayer(layer)
        }
    }

    @objc private func sipCallStateReady(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let callUUID = userInfo["callUUID"] as? UInt,
              let state = userInfo["state"] as? Int32 else { return }
        if callParam.callUUID == callUUID {
            // 呼叫断开
            if state == CALL_STATE_DISCONNECTED.rawValue {
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoContainerView.frame = view.bounds
        videoLayer?.frame = videoContainerView.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
