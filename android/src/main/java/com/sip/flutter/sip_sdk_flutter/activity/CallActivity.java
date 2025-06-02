package com.sip.flutter.sip_sdk_flutter.activity;

import static com.sip.sdk.entity.SDKConstants.SDK_CALL_TYPE_IP;

import android.Manifest;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.opengl.GLSurfaceView;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.sip.flutter.sip_sdk_flutter.R;
import com.sip.flutter.sip_sdk_flutter.activity.entity.CMSIPSDKCallParam;
import com.sip.flutter.sip_sdk_flutter.codes.H264CodecImpl;
import com.sip.flutter.sip_sdk_flutter.utils.audio.AudioHandle;
import com.sip.flutter.sip_sdk_flutter.utils.camera.CameraHandle;
import com.sip.flutter.sip_sdk_flutter.utils.camera.CameraStateChangeCallback;
import com.sip.flutter.sip_sdk_flutter.view.cameragl.YUVRenderer;
import com.sip.sdk.SIPSDK;
import com.sip.sdk.entity.SDKConstants;
import com.sip.sdk.i.SIPSDKListener;

public class CallActivity extends AppCompatActivity implements
        View.OnClickListener,
        SIPSDKListener.CallStateListener,
        H264CodecImpl.DecodeCallback,
        CameraStateChangeCallback {
    private final String TAG = CallActivity.class.getName();
    private static final int REQUEST_CAMERA_AND_AUDIO = 1000;
    private TextView tViewAnswer;
    private GLSurfaceView glSurfaceView;
    private YUVRenderer yuvRenderer;
    private View iChatControl;
    private TextView tViewSwitchMute, tViewHandFree, tViewOpenCamera, tViewSwitchCamera;
    private CMSIPSDKCallParam callParam;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        getWindow().getDecorView().setSystemUiVisibility(
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                        | WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                        | WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                        | WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
                        | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                        | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                        | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
        );
        getWindow().setStatusBarColor(Color.TRANSPARENT); // 状态栏透明
        getWindow().setNavigationBarColor(Color.TRANSPARENT); // 导航栏透明（可选）

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            getWindow().setStatusBarColor(Color.TRANSPARENT);
        }
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_call);
        callParam = (CMSIPSDKCallParam) getIntent().getSerializableExtra("callParam");
        iChatControl = findViewById(R.id.iChatControl);
        glSurfaceView = findViewById(R.id.glSurfaceView);
        glSurfaceView.setEGLContextClientVersion(2);
        yuvRenderer = new YUVRenderer(glSurfaceView);
        glSurfaceView.setRenderer(yuvRenderer);
        glSurfaceView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (iChatControl.getVisibility() == View.VISIBLE) {
                    iChatControl.setVisibility(View.GONE);
                } else {
                    iChatControl.setVisibility(View.VISIBLE);
                }
            }
        });

        tViewSwitchMute = findViewById(R.id.tViewSwitchMute);
        tViewSwitchMute.setOnClickListener(this);

        tViewHandFree = findViewById(R.id.tViewHandFree);
        tViewHandFree.setOnClickListener(this);

        tViewOpenCamera = findViewById(R.id.tViewOpenCamera);
        tViewOpenCamera.setOnClickListener(this);

        tViewSwitchCamera = findViewById(R.id.tViewSwitchCamera);
        tViewSwitchCamera.setOnClickListener(this);

        tViewAnswer = findViewById(R.id.tViewAnswer);
        tViewAnswer.setOnClickListener(this);
        findViewById(R.id.tViewHangUp).setOnClickListener(this);

        findViewById(R.id.tViewSwitchMute).setOnClickListener(this);
        findViewById(R.id.tViewHandFree).setOnClickListener(this);
        findViewById(R.id.tViewOpenCamera).setOnClickListener(this);
        findViewById(R.id.tViewSwitchCamera).setOnClickListener(this);

        SIPSDK.addListener(this);

        if (callParam.direction == 0) {
            tViewAnswer.setVisibility(View.VISIBLE);
        } else {
            if (callParam.callType == SDK_CALL_TYPE_IP) {
                callParam.callUuid = SIPSDK.callIP(callParam.remoteIp, callParam.headers);
            } else {
                callParam.callUuid = SIPSDK.call(callParam.username, callParam.headers);
            }
        }
        H264CodecImpl.addListener(this);
        String[] permissions = {
                Manifest.permission.CAMERA,
                Manifest.permission.RECORD_AUDIO
        };
        //请求摄像头权限、录音权限
        cmRequestPermissions(permissions, REQUEST_CAMERA_AND_AUDIO);
        CameraHandle.instance().addStateChangeCallback(this);
    }

    private void cmRequestPermissions(String[] permissions, int code) {
        for (String permission : permissions) {
            if (ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED && Manifest.permission.CAMERA.equals(permission)) {
                Log.i(TAG, "Permission Camera Success");
            }
        }
        ActivityCompat.requestPermissions(this, permissions, code);
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        if (hasFocus) {
            tViewSwitchMute.setSelected(AudioHandle.instance().isMicrophoneMute());
            //默认开启免提
            AudioHandle.instance().speakerSwitch(true);
            tViewHandFree.setSelected(AudioHandle.instance().isSpeakerphoneOn());
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == REQUEST_CAMERA_AND_AUDIO) {
            for (int i = 0; i < permissions.length; i++) {
                String permission = permissions[i];
                int result = grantResults[i];
                if (result == PackageManager.PERMISSION_GRANTED) {
                    if (Manifest.permission.CAMERA.equals(permission)) {
                        Log.i(TAG, "Permission Camera Success");
                    }
                } else {
                    if (Manifest.permission.CAMERA.equals(permission)) {
                        Toast.makeText(this, "相机权限被拒绝！", Toast.LENGTH_SHORT).show();
                    } else if (Manifest.permission.RECORD_AUDIO.equals(permission)) {
                        Toast.makeText(this, "录音权限被拒绝！", Toast.LENGTH_SHORT).show();
                    }
                }
            }
        }
    }

    @Override
    public void onClick(View view) {
        int id = view.getId();
        if (id == R.id.tViewSwitchMute) {
            AudioHandle.instance().microphoneMuteSwitch(!AudioHandle.instance().isMicrophoneMute());
            tViewSwitchMute.setSelected(AudioHandle.instance().isMicrophoneMute());
        } else if (id == R.id.tViewHandFree) {
            AudioHandle.instance().speakerSwitch(!AudioHandle.instance().isSpeakerphoneOn());
            tViewHandFree.setSelected(AudioHandle.instance().isSpeakerphoneOn());
        } else if (id == R.id.tViewOpenCamera) {
            CameraHandle.instance().openCloseCamera();
        } else if (id == R.id.tViewSwitchCamera) {
            CameraHandle.instance().cameraSwitch();
        } else if (id == R.id.tViewAnswer) {
            SIPSDK.answer(200);
            tViewAnswer.setVisibility(View.GONE);
        } else if (id == R.id.tViewHangUp) {
            SIPSDK.hangup(200);
            finish();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        //关闭声音
        AudioHandle.instance().destroy();
        //关闭摄像头
        CameraHandle.instance().close();
        //恢复外放
        AudioHandle.instance().speakerSwitch(true);
        //取消静音
        AudioHandle.instance().microphoneMuteSwitch(false);
        SIPSDK.removeListener(this);
        H264CodecImpl.removeListener(this);
        CameraHandle.instance().removeStateChangeCallback(this);
    }

    @Override
    public void onCallState(long callUuid, int state) {
        if (callParam.callUuid == callUuid) {
            if (SDKConstants.CALL_STATE_CONFIRMED == state) {
                //开启摄像头
                tViewOpenCamera.post(new Runnable() {
                    @Override
                    public void run() {
                        CameraHandle.instance().open();
                    }
                });
                //开启声音
                AudioHandle.instance().init();
            } else if (SDKConstants.CALL_STATE_DISCONNECTED == state) {
                finish();
            }
        }
    }

    @Override
    public void onCallback(long callUuid,
                           byte[] outData,
                           int[] outDataSize,
                           int width,
                           int height) {
        if (width == 0 || height == 0) {
            return;
        }
        yuvRenderer.update(outData, width, height);
    }

    @Override
    public void onStateChange(boolean runing) {
        tViewOpenCamera.post(new Runnable() {
            @Override
            public void run() {
                tViewOpenCamera.setSelected(runing);
            }
        });
    }
}