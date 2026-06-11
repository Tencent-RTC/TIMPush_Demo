package com.tencent.qcloud.tim.tuikit;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;

import com.tencent.qcloud.tim.push.TIMPushCallback;
import com.tencent.qcloud.tim.push.TIMPushManager;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.util.ToastUtil;

import org.jetbrains.annotations.Nullable;

public class MainActivity extends AppCompatActivity {
    private final static String TAG = MainActivity.class.getSimpleName();

    public static final int SDK_APP_ID = 0;
    public static final String APP_KEY = "";

    private EditText registrationIdEditView;
    private TextView registrationIdResultView;
    private TextView registerStateView;
    private TextView resultView;
    private View statusDotView;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initView();
        registerPush(false);
        handlePushIntent(getIntent());
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        handlePushIntent(intent);
    }

    private void initView() {
        setContentView(R.layout.test_push_layout);

        registrationIdEditView = findViewById(R.id.registration_id);
        registrationIdResultView = findViewById(R.id.get_registration_id);
        registerStateView = findViewById(R.id.tv_register_state);
        resultView = findViewById(R.id.tv_log);
        statusDotView = findViewById(R.id.status_dot);

        TextView sdkAppIdView = findViewById(R.id.tv_sdk_app_id);
        sdkAppIdView.setText(getString(R.string.push_sdk_app_id) + ": " + SDK_APP_ID);

        findViewById(R.id.btn_copy_registration_id).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                copyRegistrationId();
            }
        });
        findViewById(R.id.btn_clear_log).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                clearResult();
            }
        });

        setRegisterStatus(R.string.push_status_idle, R.color.push_idle);
    }

    private void handlePushIntent(Intent intent) {
        if (intent == null) {
            return;
        }
        String ext = intent.getStringExtra(TUIConstants.TIMPush.NOTIFICATION_EXT_KEY);
        if (!TextUtils.isEmpty(ext)) {
            Log.d(TAG, ext);
            ToastUtil.toastLongMessage(ext);
            showResult("通知点击", ext);
        }
    }

    public void registerTPush(View view) {
        registerPush(true);
    }

    private void registerPush(final boolean showToast) {
        setRegisterStatus(R.string.push_status_registering, R.color.push_warning);
        showResult("注册推送", "正在注册...");
        TIMPushManager.getInstance().registerPush(getBaseContext(), SDK_APP_ID, APP_KEY, new TIMPushCallback() {
            @Override
            public void onSuccess(Object data) {
                final String token = data == null ? "" : String.valueOf(data);
                Log.d(TAG, "registerPush success, token = " + token);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (showToast) {
                            ToastUtil.toastShortMessage("registerPush success");
                        }
                        setRegisterStatus(R.string.push_status_registered, R.color.push_success);
                        showResult("注册成功", "正在获取 RegistrationID...");
                        refreshRegistrationId("注册成功");
                    }
                });
            }

            @Override
            public void onError(final int errCode, final String errMsg, Object data) {
                Log.e(TAG, "registerPush errorCode = " + errCode + ", errorMessage = " + errMsg);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (showToast) {
                            ToastUtil.toastShortMessage("registerPush error code=" + errCode);
                        }
                        setRegisterStatus(R.string.push_status_failed, R.color.push_error);
                        showResult("注册失败", "code=" + errCode + ", msg=" + errMsg);
                    }
                });
            }
        });
    }

    public void unRegisterTPush(View view) {
        showResult("注销推送", "正在注销...");
        TIMPushManager.getInstance().unRegisterPush(new TIMPushCallback() {
            @Override
            public void onSuccess(Object data) {
                Log.d(TAG, "unRegisterPush success");
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        ToastUtil.toastShortMessage("unRegisterPush success");
                        setRegisterStatus(R.string.push_status_idle, R.color.push_idle);
                        registrationIdResultView.setText(getString(R.string.push_empty_value));
                        showResult("注销成功", "推送注册已注销");
                    }
                });
            }

            @Override
            public void onError(final int errCode, final String errMsg, Object data) {
                Log.e(TAG, "unRegisterPush errorCode = " + errCode + ", errorMessage = " + errMsg);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        ToastUtil.toastShortMessage("unRegisterPush error code=" + errCode);
                        showResult("注销失败", "code=" + errCode + ", msg=" + errMsg);
                    }
                });
            }
        });
    }

    public void getRegistrationId(View view) {
        showResult("刷新 RegistrationID", "正在获取...");
        refreshRegistrationId("获取成功");
    }

    private void refreshRegistrationId(final String resultTitle) {
        TIMPushManager.getInstance().getRegistrationID(new TIMPushCallback() {
            @Override
            public void onSuccess(Object data) {
                final String registrationId = data == null ? "" : String.valueOf(data);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        String value = TextUtils.isEmpty(registrationId)
                                ? getString(R.string.push_empty_value) : registrationId;
                        registrationIdResultView.setText(value);
                        showResult(resultTitle, "RegistrationID: " + value);
                    }
                });
            }
        });
    }

    public void setRegistrationId(View view) {
        final String registrationId = registrationIdEditView.getText() == null
                ? "" : registrationIdEditView.getText().toString().trim();
        if (TextUtils.isEmpty(registrationId)) {
            ToastUtil.toastShortMessage("registrationId is null");
            showResult("设置失败", "RegistrationID 不能为空");
            return;
        }

        showResult("设置 RegistrationID", "正在设置...");
        TIMPushManager.getInstance().setRegistrationID(registrationId, new TIMPushCallback() {
            @Override
            public void onSuccess(Object data) {
                Log.d(TAG, "setRegistrationId success");
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        ToastUtil.toastShortMessage("setRegistrationId success");
                        registrationIdResultView.setText(registrationId);
                        showResult("设置成功", "RegistrationID: " + registrationId);
                    }
                });
            }
        });
    }

    private void setRegisterStatus(int statusTextRes, int statusColorRes) {
        int color = ContextCompat.getColor(this, statusColorRes);
        registerStateView.setText(statusTextRes);
        registerStateView.setTextColor(color);
        if (statusDotView.getBackground() != null) {
            statusDotView.getBackground().mutate().setTint(color);
        }
    }

    private void showResult(String title, String detail) {
        if (resultView == null) {
            return;
        }
        resultView.setText(TextUtils.isEmpty(detail) ? title : title + "\n" + detail);
    }

    private void clearResult() {
        if (resultView != null) {
            resultView.setText(getString(R.string.push_result_empty));
        }
    }

    private void copyRegistrationId() {
        CharSequence registrationId = registrationIdResultView.getText();
        if (TextUtils.isEmpty(registrationId) || getString(R.string.push_empty_value).contentEquals(registrationId)) {
            ToastUtil.toastShortMessage("RegistrationID is empty");
            return;
        }
        ClipboardManager clipboardManager = (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
        if (clipboardManager != null) {
            clipboardManager.setPrimaryClip(ClipData.newPlainText("RegistrationID", registrationId));
            ToastUtil.toastShortMessage(getString(R.string.push_copy_success));
            showResult("复制成功", "RegistrationID 已复制到剪贴板");
        }
    }
}
