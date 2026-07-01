import { TIMPushManager, TIMPushResult } from '@tencentcloud/timpush';
import { preferences } from '@kit.ArkData';

const SDK_APP_ID: number = 0;
const APP_KEY: string = '';
const LOADING_VALUE: string = '正在获取...';
const EMPTY_VALUE: string = '暂无推送 ID';
const RESULT_EMPTY: string = '暂无结果';
const PREFS_NAME: string = 'timpush_demo_prefs';
const KEY_CUSTOM_ID: string = 'custom_registration_id';

@Entry
@Component
struct Index {
  @State private registrationID: string = LOADING_VALUE;
  @State private registerState: string = '未注册';
  @State private registerStateColor: string = '#98A2B3';
  @State private resultText: string = RESULT_EMPTY;
  @State private customRegistrationID: string = '';

  aboutToAppear(): void {
    this.registerWithPersistedId(false);
  }

  private showResult(title: string, detail?: string): void {
    this.resultText = detail && detail.length > 0 ? `${title}\n${detail}` : title;
  }

  private registrationIDFromResult(result: TIMPushResult): string {
    const data = result.data as string | Record<string, string> | null | undefined;
    if (typeof data === 'string') {
      return data.trim();
    }
    if (data !== null && data !== undefined) {
      const value = data['registrationID'] || data['registrationId'] || data['RegistrationID'] || data['token'] || data['pushToken'];
      return value ? value.trim() : '';
    }
    return result.message ? result.message.trim() : '';
  }

  // 统一注册入口：注册前先把"正确的 ID"写入 SDK 内存（自定义值或空串清空），再 registerPush。
  // setRegistrationID 必须在 registerPush 之前调用才会生效。
  private async registerWithPersistedId(showToast: boolean): Promise<void> {
    this.registerState = '注册中';
    this.registerStateColor = '#FF8A00';
    this.showResult('注册推送', '正在注册...');
    const customID = await this.getCustomRegistrationID();
    try {
      // 有自定义值则用自定义值；无则用空串清空 SDK 内存里的残留，让其回退默认 ID
      await TIMPushManager.getInstance().setRegistrationID(customID.length > 0 ? customID : '');
    } catch (error) {
      // 即使设置失败也继续注册，避免阻塞
    }
    this.doRegisterPush(showToast);
  }

  // 实际执行 registerPush，成功后通过 getRegistrationID 刷新展示真实生效的 ID
  private doRegisterPush(showToast: boolean): void {
    TIMPushManager.getInstance()
      .registerPush(getContext(), SDK_APP_ID, APP_KEY)
      .then((result) => {
        this.registerState = '已注册';
        this.registerStateColor = '#00A870';
        const registeredID = this.registrationIDFromResult(result);
        if (registeredID.length > 0) {
          this.registrationID = registeredID;
        }
        this.refreshRegistrationID('注册成功', registeredID);
      })
      .catch((error: Error) => {
        this.registerState = '注册失败';
        this.registerStateColor = '#E34D59';
        this.registrationID = EMPTY_VALUE;
        this.showResult('注册失败', JSON.stringify(error));
      });
  }

  // 重置默认 ID：清除本地持久化并重新注册，恢复 SDK 默认生成的推送 ID
  // 重置默认 ID：清除 Demo 持久化 → 显式 set 空串清掉 SDK 缓存 → 反注册，回到未注册态
  private async resetRegistrationID(): Promise<void> {
    await this.clearCustomRegistrationID();
    this.showResult('重置默认 ID', '正在清除自定义推送 ID 并反注册...');
    // SDK 内部也缓存了 RegistrationID，先 set 空串清掉
    try {
      await TIMPushManager.getInstance().setRegistrationID('');
    } catch (error) {
      // 即使清空失败也继续反注册，避免阻塞
    }
    // 反注册，清除当前登录态/token
    TIMPushManager.getInstance()
      .unRegisterPush()
      .then(() => {
        this.registerState = '未注册';
        this.registerStateColor = '#98A2B3';
        this.registrationID = EMPTY_VALUE;
        this.showResult('重置成功', '已清除自定义推送 ID 并反注册，重新注册或下次启动将使用默认 ID');
      })
      .catch((error: Error) => {
        this.showResult('重置失败', JSON.stringify(error));
      });
  }

  private async getCustomRegistrationID(): Promise<string> {
    try {
      const store = await preferences.getPreferences(getContext(), PREFS_NAME);
      const value = await store.get(KEY_CUSTOM_ID, '');
      return typeof value === 'string' ? value : '';
    } catch (error) {
      return '';
    }
  }

  private async saveCustomRegistrationID(id: string): Promise<void> {
    try {
      const store = await preferences.getPreferences(getContext(), PREFS_NAME);
      await store.put(KEY_CUSTOM_ID, id);
      await store.flush();
    } catch (error) {
      // ignore persistence error in demo
    }
  }

  private async clearCustomRegistrationID(): Promise<void> {
    try {
      const store = await preferences.getPreferences(getContext(), PREFS_NAME);
      await store.delete(KEY_CUSTOM_ID);
      await store.flush();
    } catch (error) {
      // ignore persistence error in demo
    }
  }

  private unRegisterPush(): void {
    this.showResult('注销推送', '正在注销...');
    TIMPushManager.getInstance()
      .unRegisterPush()
      .then(() => {
        this.registerState = '未注册';
        this.registerStateColor = '#98A2B3';
        this.registrationID = EMPTY_VALUE;
        this.showResult('注销成功', '推送注册已注销');
      })
      .catch((error: Error) => {
        this.showResult('注销失败', JSON.stringify(error));
      });
  }

  private refreshRegistrationID(title: string = '获取成功', fallbackID: string = ''): void {
    const fallbackValue = fallbackID.length > 0 ? fallbackID : '';
    if (fallbackValue.length > 0) {
      this.registrationID = fallbackValue;
    } else if (this.registrationID === LOADING_VALUE) {
      this.registrationID = EMPTY_VALUE;
    }
    this.showResult('刷新 RegistrationID', '正在获取...');
    TIMPushManager.getInstance()
      .getRegistrationID()
      .then((result) => {
        const value = this.registrationIDFromResult(result);
        const displayValue = value.length > 0 ? value : fallbackValue;
        this.registrationID = displayValue.length > 0 ? displayValue : EMPTY_VALUE;
        this.showResult(title, displayValue.length > 0 ? `RegistrationID: ${displayValue}` : 'RegistrationID 为空，请稍后刷新');
      })
      .catch((error: Error) => {
        this.registrationID = fallbackValue.length > 0 ? fallbackValue : EMPTY_VALUE;
        this.showResult('获取失败', fallbackValue.length > 0 ? `RegistrationID: ${fallbackValue}` : JSON.stringify(error));
      });
  }

  private setRegistrationID(): void {
    const value = this.customRegistrationID.trim();
    if (value.length === 0) {
      this.showResult('设置失败', 'RegistrationID 不能为空');
      return;
    }
    this.showResult('设置 RegistrationID', '正在设置...');
    // 先持久化，再走统一注册入口（注册前会把该自定义 ID 设入 SDK 并重新注册使其生效）
    this.saveCustomRegistrationID(value).then(() => {
      this.showResult('设置成功', '已持久化，正在重新注册以使自定义推送 ID 生效...');
      this.registerWithPersistedId(false);
    });
  }

  build() {
    Column() {
      Column() {
        Text('TIMPush Demo')
          .fontColor(Color.White)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width('100%')
        Text('启动后自动注册，获取推送 ID 用于发送测试')
          .fontColor('#D7E8FF')
          .fontSize(13)
          .margin({ top: 6 })
          .width('100%')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 26, bottom: 20 })
      .linearGradient({ angle: 90, colors: [['#006EFF', 0], ['#0047B3', 1]] })

      Scroll() {
        Column() {
          this.PushIdCard()
          this.ActionCard()
          this.ResultCard()
        }
        .width('100%')
      }
      .layoutWeight(1)
      .padding(16)
      .backgroundColor('#F5F7FA')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder
  private PushIdCard() {
    Column() {
      this.SectionTitle('推送 ID')
      Text('将该 ID 填入控制台或服务端接口，即可向当前设备发送测试推送。')
        .fontColor('#667085')
        .fontSize(13)
        .margin({ top: 6 })
        .width('100%')
      Column() {
        Text(this.registrationID)
          .logBoxStyle(72, 15)
      }
      .margin({ top: 14 })
      Row() {
        Circle()
          .width(8)
          .height(8)
          .fill(this.registerStateColor)
          .margin({ right: 8 })
        Text(this.registerState)
          .fontColor(this.registerStateColor)
          .fontSize(13)
          .layoutWeight(1)
      }
      .width('100%')
      .margin({ top: 12 })
      Row() {
        this.DemoButton('复制', true, () => this.showResult('复制成功', 'RegistrationID 已复制到剪贴板'))
        Blank().width(12)
        this.DemoButton('刷新', false, () => this.refreshRegistrationID())
      }
      .margin({ top: 14 })
      .width('100%')
    }
    .cardStyle()
  }

  @Builder
  private ActionCard() {
    Column() {
      this.SectionTitle('更多操作')
      TextInput({ placeholder: '输入新的推送 ID', text: this.customRegistrationID })
        .height(46)
        .width('100%')
        .fontSize(14)
        .placeholderColor('#98A2B3')
        .backgroundColor(Color.White)
        .border({ width: 1, color: '#E5E8EF', radius: 10 })
        .padding({ left: 12, right: 12 })
        .margin({ top: 14 })
        .onChange((value: string) => {
          this.customRegistrationID = value;
        })
      Row() {
        this.DemoButton('自定义推送 ID', false, () => this.setRegistrationID())
        Blank().width(12)
        this.DemoButton('重置推送 ID', false, () => { this.resetRegistrationID(); })
      }
      .margin({ top: 12 })
      .width('100%')
      Row() {
        this.DemoButton('重新注册', false, () => { this.registerWithPersistedId(true); })
        Blank().width(12)
        this.DemoButton('注销推送', false, () => this.unRegisterPush())
      }
      .margin({ top: 12 })
      .width('100%')
    }
    .cardStyle()
    .margin({ top: 12 })
  }

  @Builder
  private ResultCard() {
    Column() {
      Row() {
        this.SectionTitle('结果')
        Blank().layoutWeight(1)
        Text('清空')
          .fontColor('#667085')
          .fontSize(13)
          .height(32)
          .padding({ left: 10, right: 10 })
          .onClick(() => {
            this.resultText = RESULT_EMPTY;
          })
      }
      .width('100%')
      Column() {
        Text(this.resultText)
          .logBoxStyle(56, 13)
      }
      .margin({ top: 10 })
    }
    .cardStyle()
    .margin({ top: 12 })
  }

  @Builder
  private SectionTitle(text: string) {
    Text(text)
      .fontColor('#1F2937')
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .width('100%')
  }

  @Builder
  private DemoButton(label: string, primary: boolean, onClick: () => void) {
    Button(label, { type: ButtonType.Normal })
      .height(44)
      .layoutWeight(1)
      .fontSize(14)
      .fontColor(primary ? Color.White : '#006EFF')
      .backgroundColor(primary ? '#006EFF' : Color.White)
      .border({ width: primary ? 0 : 1, color: '#006EFF', radius: 10 })
      .onClick(onClick)
  }
}

@Extend(Column)
function cardStyle() {
  .width('100%')
  .padding(16)
  .backgroundColor(Color.White)
  .borderRadius(14)
}

@Extend(Text)
function logBoxStyle(minHeight: number, fontSize: number) {
  .fontColor('#1F2937')
  .fontSize(fontSize)
  .width('100%')
  .constraintSize({ minHeight })
  .padding(12)
  .backgroundColor('#F8FAFC')
  .border({ width: 1, color: '#E5E8EF', radius: 10 })
}
