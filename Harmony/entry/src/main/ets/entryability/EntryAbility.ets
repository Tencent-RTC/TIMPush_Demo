import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { TIMPushListener, TIMPushManager, TIMPushMessage } from '@tencentcloud/timpush';
import { V2TIMManager } from '@tencentcloud/imsdk';

const TAG: string = 'TIMPushDemo';
const SDK_APP_ID: number = 0;
const APP_KEY: string = '';

export default class EntryAbility extends UIAbility {
  private pushListener: TIMPushListener = {
    onMessageReceived: (message: TIMPushMessage) => {
      hilog.info(0x0000, TAG, 'onMessageReceived %{public}s', JSON.stringify(message));
    },
    onNotificationClicked: (data: string) => {
      hilog.info(0x0000, TAG, 'onNotificationClicked %{public}s', data);
    },
    onRevokePushMessage: (messageID: string) => {
      hilog.info(0x0000, TAG, 'onRevokePushMessage %{public}s', messageID);
    },
  };

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'EntryAbility onCreate');
    TIMPushManager.getInstance().addPushListener(this.pushListener);
    V2TIMManager.getInstance().initSDK(this.context.getApplicationContext(), SDK_APP_ID);
    TIMPushManager.getInstance()
      .registerPush(this.context, SDK_APP_ID, APP_KEY)
      .then((result) => {
        hilog.info(0x0000, TAG, 'registerPush success %{public}s', result.message);
      })
      .catch((error: Error) => {
        hilog.error(0x0000, TAG, 'registerPush failed %{public}s', JSON.stringify(error));
      });
  }

  onDestroy(): void {
    TIMPushManager.getInstance().removePushListener(this.pushListener);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, TAG, 'Failed to load content. code=%{public}d, message=%{public}s', err.code, err.message);
      }
    });
  }
}
