package com.tencent.qcloud.tim.tuikit;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
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

import androidx.annotation.Nullable;

public class MainActivity extends AppCompatActivity {
    private final static String TAG = MainActivity.class.getSimpleName();

    public static final int SDK_APP_ID = 0;
    public static final String APP_KEY = "";
    private static final String PREFS_NAME = "timpush_demo_prefs";
    private static final String KEY_CUSTOM_REGISTRATION_ID = "custom_registration_id";

    private EditText registrationIdEditView;
    private TextView registrationIdResultView;
    private TextView registerStateView;
    private TextView resultView;
    private View statusDotView;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initView();
        registerWithPersistedId(false);
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
        registerWithPersistedId(true);
    }

    // 统一注册入口：注册前先把"正确的 ID"写入 SDK 内存（自定义值或空串清空），再 registerPush。
    // setRegistrationID 必须在 registerPush 之前调用才会生效。
    private void registerWithPersistedId(final boolean showToast) {
        setRegisterStatus(R.string.push_status_registering, R.color.push_warning);
        showResult("注册推送", "正在注册...");
        final String customId = getCustomRegistrationId();
        // 有自定义值则用自定义值；无则用空串清空 SDK 内存里的残留，让其回退默认 ID
        TIMPushManager.getInstance().setRegistrationID(customId == null ? "" : customId, new TIMPushCallback() {
            @Override
            public void onSuccess(Object data) {
                doRegisterPush(showToast);
            }

            @Override
            public void onError(int errCode, String errMsg, Object data) {
                // 即使设置失败也继续注册，避免阻塞
                doRegisterPush(showToast);
            }
        });
    }

    // 实际执行 registerPush，成功后通过 getRegistrationID 刷新展示真实生效的 ID
    private void doRegisterPush(final boolean showToast) {
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
        // 先持久化，再走统一注册入口（注册前会把该自定义 ID 设入 SDK 并重新注册使其生效）
        saveCustomRegistrationId(registrationId);
        ToastUtil.toastShortMessage("setRegistrationId success");
        showResult("设置成功", "已持久化，正在重新注册以使自定义推送 ID 生效...");
        registerWithPersistedId(false);
    }

    // 重置默认 ID：清除本地持久化的自定义推送 ID，并重新注册以恢复 SDK 默认生成
    // 重置默认 ID：清除 Demo 持久化 → 显式 set 空串清掉 SDK 缓存 → 反注册，回到未注册态
    public void resetRegistrationId(View view) {
        clearCustomRegistrationId();
        showResult("重置默认 ID", "正在清除自定义推送 ID 并反注册...");
        // SDK 内部也缓存了 RegistrationID，先 set 空串清掉
        TIMPushManager.getInstance().setRegistrationID("", new TIMPushCallback() {
            @Override
            public void onSuccess(Object data) {
                resetUnRegister();
            }

            @Override
            public void onError(int errCode, String errMsg, Object data) {
                resetUnRegister();
            }
        });
    }

    // 重置流程第二步：反注册，清除当前登录态/token
    private void resetUnRegister() {
        TIMPushManager.getInstance().unRegisterPush(new TIMPushCallback() {
            @Override
            public void onSuccess(Object data) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        ToastUtil.toastShortMessage("已重置为 SDK 默认推送 ID");
                        setRegisterStatus(R.string.push_status_idle, R.color.push_idle);
                        registrationIdResultView.setText(getString(R.string.push_empty_value));
                        showResult("重置成功", "已清除自定义推送 ID 并反注册，重新注册或下次启动将使用默认 ID");
                    }
                });
            }

            @Override
            public void onError(final int errCode, final String errMsg, Object data) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        showResult("重置失败", "反注册失败 code=" + errCode + ", msg=" + errMsg);
                    }
                });
            }
        });
    }

    private SharedPreferences getPrefs() {
        return getApplicationContext().getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
    }

    private String getCustomRegistrationId() {
        return getPrefs().getString(KEY_CUSTOM_REGISTRATION_ID, "");
    }

    private void saveCustomRegistrationId(String registrationId) {
        getPrefs().edit().putString(KEY_CUSTOM_REGISTRATION_ID, registrationId).apply();
    }

    private void clearCustomRegistrationId() {
        getPrefs().edit().remove(KEY_CUSTOM_REGISTRATION_ID).apply();
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
