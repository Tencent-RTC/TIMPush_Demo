package com.tencent.qcloud.tim.tuikit;

import android.content.Intent;
import android.util.Log;

import androidx.multidex.MultiDexApplication;

import com.tencent.qcloud.tim.push.TIMPushListener;
import com.tencent.qcloud.tim.push.TIMPushManager;
import com.tencent.qcloud.tim.push.TIMPushMessage;
import com.tencent.qcloud.tim.push.utils.TIMPushLog;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.util.ToastUtil;

public class DemoApplication extends MultiDexApplication {
    private static final String TAG = DemoApplication.class.getSimpleName();

    @Override
    public void onCreate() {
        Log.i(TAG, "onCreate");
        super.onCreate();

        TIMPushManager.getInstance().addPushListener(new TIMPushListener() {
            @Override
            public void onRecvPushMessage(TIMPushMessage msg) {
                Log.d(TAG, "onRecvPushMessage =" + msg.toString());
            }

            @Override
            public void onRevokePushMessage(String msgID) {
                Log.d(TAG, "onRevokePushMessage =" + msgID);
            }

            @Override
            public void onNotificationClicked(String ext) {
                String notificationClickedExt = "onNotificationClicked =" + ext;
                Log.d(TAG, notificationClickedExt);
                ToastUtil.toastLongMessage(notificationClickedExt);

                try {
                    Intent intent = new Intent();
                    intent.setClassName(getApplicationContext(), "com.tencent.qcloud.tim.tuikit.MainActivity");
                    intent.putExtra(TUIConstants.TIMPush.NOTIFICATION_EXT_KEY, ext);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    getApplicationContext().startActivity(intent);
                } catch (Exception e) {
                    TIMPushLog.e(TAG, "start MainActivity e = " + e);
                }
            }
        });
    }
}
