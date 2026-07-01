declare module '@tencentcloud/react-native-push' {
  type PushCallback<T = string> = (data: T) => void;
  type PushErrorCallback = (errCode: number, errMsg: string) => void;

  export default class Push {
    static EVENT: {
      MESSAGE_RECEIVED: string;
      MESSAGE_REVOKED: string;
      NOTIFICATION_CLICKED: string;
    };

    static registerPush(
      SDKAppID: number,
      appKey: string,
      onSuccess: PushCallback,
      onError?: PushErrorCallback,
    ): void;
    static unRegisterPush(onSuccess: () => void, onError?: PushErrorCallback): void;
    static getRegistrationID(onSuccess: PushCallback): void;
    static setRegistrationID(registrationID: string, onSuccess: () => void): void;
    static getNotificationExtInfo(onSuccess: PushCallback): void;
    static addPushListener(eventName: string, listener: (data: unknown) => void): void;
    static removePushListener(eventName: string, listener?: (data: unknown) => void): void;
    static disablePostNotificationInForeground(disable: boolean): void;
    static createNotificationChannel(options: Record<string, unknown>, onSuccess: PushCallback): void;
  }
}
