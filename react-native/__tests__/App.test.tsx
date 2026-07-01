/**
 * @format
 */

import 'react-native';
import React from 'react';
import renderer, {act} from 'react-test-renderer';
import {expect, it, jest} from '@jest/globals';
import {Text, TextInput, TouchableOpacity} from 'react-native';
import App from '../App';
import Push from '@tencentcloud/react-native-push';
import Clipboard from '@react-native-clipboard/clipboard';

jest.mock('@tencentcloud/react-native-push', () => ({
  EVENT: {
    MESSAGE_RECEIVED: 'message_received',
    MESSAGE_REVOKED: 'message_revoked',
    NOTIFICATION_CLICKED: 'notification_clicked',
  },
  registerPush: jest.fn(),
  unRegisterPush: jest.fn(),
  getRegistrationID: jest.fn(),
  setRegistrationID: jest.fn(),
  getNotificationExtInfo: jest.fn(),
  addPushListener: jest.fn(),
  removePushListener: jest.fn(),
  disablePostNotificationInForeground: jest.fn(),
}));

jest.mock('@react-native-clipboard/clipboard', () => ({
  setString: jest.fn(),
}), {virtual: true});

const textContent = (root: renderer.ReactTestInstance) =>
  root
    .findAllByType(Text)
    .map(node => node.props.children)
    .flat(Number.POSITIVE_INFINITY)
    .filter(Boolean)
    .join(' ');

it('renders controls aligned with Android TIMPush demo', async () => {
  (Push.registerPush as jest.Mock).mockImplementation((...args: unknown[]) => {
    const onSuccess = args[2] as (token: string) => void;
    onSuccess('token');
  });
  (Push.getRegistrationID as jest.Mock).mockImplementation((...args: unknown[]) => {
    const onSuccess = args[0] as (registrationId: string) => void;
    onSuccess('registration-id');
  });

  let tree!: renderer.ReactTestRenderer;
  await act(async () => {
    tree = renderer.create(<App />);
  });

  const text = textContent(tree.root);

  expect(text).toContain('TIMPush Demo');
  expect(text).toContain('启动后自动注册，获取推送 ID 用于发送测试');
  expect(text).toContain('推送 ID');
  expect(text).toContain('将该 ID 填入控制台或服务端接口，即可向当前设备发送测试推送。');
  expect(text).not.toContain('SDKAppID');
  expect(text).not.toContain('1400187352');
  expect(text).toContain('复制');
  expect(text).toContain('刷新');
  expect(text).toContain('更多操作');
  expect(text).toContain('自定义推送 ID');
  expect(text).toContain('重新注册');
  expect(text).toContain('注销推送');
  expect(text).toContain('结果');
  expect(text).toContain('清空');

  expect(text).not.toContain('AppKey');
  expect(text).not.toContain('请输入 SDKAppID');
  expect(tree.root.findAllByType(TextInput)).toHaveLength(1);
  expect(Push.registerPush).toHaveBeenCalledWith(
    1400187352,
    'ZH4kE76C5BAYgP2wlbK4iRCiAxLGTGbIh7hPTXV0T8J22ZCdp3vNsEGJgXVdlNm2',
    expect.any(Function),
    expect.any(Function),
  );
});

it('copies RegistrationID to clipboard like Android demo', async () => {
  (Push.registerPush as jest.Mock).mockImplementation((...args: unknown[]) => {
    const onSuccess = args[2] as (token: string) => void;
    onSuccess('token');
  });
  (Push.getRegistrationID as jest.Mock).mockImplementation((...args: unknown[]) => {
    const onSuccess = args[0] as (registrationId: string) => void;
    onSuccess('registration-id');
  });

  let tree!: renderer.ReactTestRenderer;
  await act(async () => {
    tree = renderer.create(<App />);
  });

  const copyButton = tree.root
    .findAllByType(TouchableOpacity)
    .find(node => node.findAllByType(Text).some(text => text.props.children === '复制'));

  expect(copyButton).toBeTruthy();
  await act(async () => {
    copyButton?.props.onPress();
  });

  expect(Clipboard.setString).toHaveBeenCalledWith('registration-id');
});
