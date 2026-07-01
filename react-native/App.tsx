import React, {useCallback, useEffect, useState} from 'react';
import {
  Alert,
  Keyboard,
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import Clipboard from '@react-native-clipboard/clipboard';
import Push from '@tencentcloud/react-native-push';

type RegisterState = 'idle' | 'registering' | 'registered' | 'failed';

const SDK_APP_ID = 0;
const APP_KEY = '';
const EMPTY_VALUE = '正在获取...';
const RESULT_EMPTY = '暂无结果';
const CUSTOM_ID_KEY = 'timpush_custom_registration_id';

const colors = {
  primary: '#006EFF',
  primaryDark: '#0047B3',
  pageBg: '#F5F7FA',
  cardBg: '#FFFFFF',
  divider: '#E5E8EF',
  textPrimary: '#1F2937',
  textSecondary: '#667085',
  textTertiary: '#98A2B3',
  textInverse: '#FFFFFF',
  success: '#00A870',
  warning: '#FF8A00',
  error: '#E34D59',
  idle: '#98A2B3',
  logBg: '#F8FAFC',
  headerSubtitle: '#D7E8FF',
};

const statusCopy: Record<RegisterState, {label: string; color: string}> = {
  idle: {label: '未注册', color: colors.idle},
  registering: {label: '注册中', color: colors.warning},
  registered: {label: '已注册', color: colors.success},
  failed: {label: '注册失败', color: colors.error},
};

function normalizeDetail(data: unknown) {
  if (typeof data === 'string') {
    return data || EMPTY_VALUE;
  }
  if (data == null) {
    return EMPTY_VALUE;
  }
  try {
    return JSON.stringify(data, null, 2);
  } catch {
    return String(data);
  }
}

function formatResult(title: string, detail?: unknown) {
  const normalizedDetail = detail == null ? '' : normalizeDetail(detail);
  return normalizedDetail ? `${title}\n${normalizedDetail}` : title;
}

function App(): React.JSX.Element {
  const [customRegistrationId, setCustomRegistrationId] = useState('');
  const [registrationId, setRegistrationId] = useState(EMPTY_VALUE);
  const [registerState, setRegisterState] = useState<RegisterState>('idle');
  const [result, setResult] = useState(RESULT_EMPTY);

  const showResult = useCallback((title: string, detail?: unknown) => {
    setResult(formatResult(title, detail));
  }, []);

  const refreshRegistrationId = useCallback((title = '获取成功') => {
    showResult('刷新 RegistrationID', '正在获取...');
    Push.getRegistrationID((id: string) => {
      const value = id || EMPTY_VALUE;
      setRegistrationId(value);
      showResult(title, `RegistrationID: ${value}`);
    });
  }, [showResult]);

  // 实际执行 registerPush，成功后通过 getRegistrationID 刷新展示真实生效的 ID
  const doRegisterPush = useCallback((showAlert = false) => {
    Push.registerPush(
      SDK_APP_ID,
      APP_KEY,
      (_token: string) => {
        if (showAlert) {
          Alert.alert('registerPush success');
        }
        setRegisterState('registered');
        showResult('注册成功', '正在获取 RegistrationID...');
        refreshRegistrationId('注册成功');
      },
      (errCode: number, errMsg: string) => {
        if (showAlert) {
          Alert.alert('registerPush error', `code=${errCode}`);
        }
        setRegisterState('failed');
        showResult('注册失败', `code=${errCode}, msg=${errMsg}`);
      },
    );
  }, [refreshRegistrationId, showResult]);

  // 统一注册入口：注册前先把"正确的 ID"写入 SDK 内存（自定义值或空串清空），再 registerPush。
  // setRegistrationID 必须在 registerPush 之前调用才会生效。
  const registerWithPersistedId = useCallback((showAlert = false) => {
    setRegisterState('registering');
    showResult('注册推送', '正在注册...');
    AsyncStorage.getItem(CUSTOM_ID_KEY)
      .then((customId: string | null) => {
        // 有自定义值则用自定义值；无则用空串清空 SDK 内存里的残留，让其回退默认 ID
        Push.setRegistrationID(customId || '', () => {
          doRegisterPush(showAlert);
        });
      })
      .catch(() => {
        Push.setRegistrationID('', () => {
          doRegisterPush(showAlert);
        });
      });
  }, [doRegisterPush, showResult]);

  const unregisterPush = useCallback(() => {
    showResult('注销推送', '正在注销...');
    Push.unRegisterPush(
      () => {
        Alert.alert('unRegisterPush success');
        setRegisterState('idle');
        setRegistrationId(EMPTY_VALUE);
        showResult('注销成功', '推送注册已注销');
      },
      (errCode: number, errMsg: string) => {
        Alert.alert('unRegisterPush error', `code=${errCode}`);
        showResult('注销失败', `code=${errCode}, msg=${errMsg}`);
      },
    );
  }, [showResult]);

  const updateRegistrationId = useCallback(() => {
    Keyboard.dismiss();
    const value = customRegistrationId.trim();
    if (!value) {
      Alert.alert('registrationId is null');
      showResult('设置失败', 'RegistrationID 不能为空');
      return;
    }

    showResult('设置 RegistrationID', '正在设置...');
    // 先持久化，再走统一注册入口（注册前会把该自定义 ID 设入 SDK 并重新注册使其生效）
    AsyncStorage.setItem(CUSTOM_ID_KEY, value)
      .catch(() => {})
      .then(() => {
        Alert.alert('setRegistrationId success');
        showResult('设置成功', '已持久化，正在重新注册以使自定义推送 ID 生效...');
        registerWithPersistedId(false);
      });
  }, [customRegistrationId, registerWithPersistedId, showResult]);

  // 重置默认 ID：清除本地持久化并重新注册，恢复 SDK 默认生成的推送 ID
  // 重置默认 ID：清除 Demo 持久化 → 显式 set 空串清掉 SDK 缓存 → 反注册，回到未注册态
  const resetRegistrationId = useCallback(() => {
    AsyncStorage.removeItem(CUSTOM_ID_KEY)
      .catch(() => {})
      .then(() => {
        showResult('重置默认 ID', '正在清除自定义推送 ID 并反注册...');
        // SDK 内部也缓存了 RegistrationID，先 set 空串清掉，再反注册
        Push.setRegistrationID('', () => {
          Push.unRegisterPush(
            () => {
              Alert.alert('已重置为 SDK 默认推送 ID');
              setRegisterState('idle');
              setRegistrationId(EMPTY_VALUE);
              showResult('重置成功', '已清除自定义推送 ID 并反注册，重新注册或下次启动将使用默认 ID');
            },
            (errCode: number, errMsg: string) => {
              showResult('重置失败', `反注册失败 code=${errCode}, msg=${errMsg}`);
            },
          );
        });
      });
  }, [showResult]);

  const shareRegistrationId = useCallback(() => {
    if (!registrationId || registrationId === EMPTY_VALUE) {
      Alert.alert('RegistrationID is empty');
      return;
    }
    Clipboard.setString(registrationId);
    Alert.alert('已复制');
    showResult('复制成功', 'RegistrationID 已复制到剪贴板');
  }, [registrationId, showResult]);

  useEffect(() => {
    const onNotificationClicked = (ext: unknown) => showResult('通知点击', ext);
    const onMessageReceived = (message: unknown) => showResult('收到在线推送', message);
    const onMessageRevoked = (messageId: unknown) => showResult('在线推送撤回', messageId);

    Push.addPushListener(Push.EVENT.NOTIFICATION_CLICKED, onNotificationClicked);
    Push.addPushListener(Push.EVENT.MESSAGE_RECEIVED, onMessageReceived);
    Push.addPushListener(Push.EVENT.MESSAGE_REVOKED, onMessageRevoked);
    Push.getNotificationExtInfo((extInfo: string) => {
      if (extInfo) {
        showResult('通知点击', extInfo);
      }
    });
    registerWithPersistedId(false);

    return () => {
      Push.removePushListener(Push.EVENT.NOTIFICATION_CLICKED, onNotificationClicked);
      Push.removePushListener(Push.EVENT.MESSAGE_RECEIVED, onMessageReceived);
      Push.removePushListener(Push.EVENT.MESSAGE_REVOKED, onMessageRevoked);
    };
  }, [registerWithPersistedId, showResult]);

  const status = statusCopy[registerState];

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar barStyle="light-content" backgroundColor={colors.primary} />
      <View style={styles.header}>
        <View style={styles.headerShade} />
        <Text style={styles.headerTitle}>TIMPush Demo</Text>
        <Text style={styles.headerSubtitle}>启动后自动注册，获取推送 ID 用于发送测试</Text>
      </View>

      <ScrollView contentContainerStyle={styles.container} keyboardShouldPersistTaps="handled">
        <View style={styles.card}>
          <Text style={styles.sectionTitle}>推送 ID</Text>
          <Text style={styles.description}>将该 ID 填入控制台或服务端接口，即可向当前设备发送测试推送。</Text>
          <Text selectable style={styles.pushIdBox}>{registrationId}</Text>

          <View style={styles.statusRow}>
            <View style={[styles.statusDot, {backgroundColor: status.color}]} />
            <Text style={[styles.statusText, {color: status.color}]}>{status.label}</Text>
          </View>

          <View style={styles.buttonRow}>
            <ActionButton title="复制" primary onPress={shareRegistrationId} />
            <View style={styles.buttonSpace} />
            <ActionButton title="刷新" onPress={() => refreshRegistrationId()} />
          </View>
        </View>

        <View style={styles.cardWithTopMargin}>
          <Text style={styles.sectionTitle}>更多操作</Text>
          <TextInput
            style={styles.input}
            value={customRegistrationId}
            onChangeText={setCustomRegistrationId}
            autoCapitalize="none"
            autoCorrect={false}
            placeholder="输入新的推送 ID"
            placeholderTextColor={colors.textTertiary}
          />
          <View style={styles.buttonRow}>
            <ActionButton title="自定义推送 ID" onPress={updateRegistrationId} />
            <View style={styles.buttonSpace} />
            <ActionButton title="重置推送 ID" onPress={resetRegistrationId} />
          </View>
          <View style={styles.buttonRow}>
            <ActionButton title="重新注册" onPress={() => registerWithPersistedId(true)} />
            <View style={styles.buttonSpace} />
            <ActionButton title="注销推送" onPress={unregisterPush} />
          </View>
        </View>

        <View style={styles.cardWithTopMargin}>
          <View style={styles.resultHeader}>
            <Text style={styles.sectionTitleFlex}>结果</Text>
            <TouchableOpacity style={styles.clearButton} onPress={() => setResult(RESULT_EMPTY)}>
              <Text style={styles.clearButtonText}>清空</Text>
            </TouchableOpacity>
          </View>
          <Text selectable style={styles.resultBox}>{result}</Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

type ActionButtonProps = {
  title: string;
  primary?: boolean;
  fullWidth?: boolean;
  onPress: () => void;
};

function ActionButton({title, primary = false, fullWidth = false, onPress}: ActionButtonProps) {
  return (
    <TouchableOpacity
      activeOpacity={0.8}
      style={[
        styles.buttonBase,
        primary ? styles.primaryButton : styles.secondaryButton,
        fullWidth ? styles.fullWidthButton : styles.flexButton,
      ]}
      onPress={onPress}>
      <Text style={[styles.buttonText, primary ? styles.primaryButtonText : styles.secondaryButtonText]}>{title}</Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.pageBg,
  },
  header: {
    backgroundColor: colors.primary,
    overflow: 'hidden',
    paddingBottom: 20,
    paddingHorizontal: 20,
    paddingTop: 26,
  },
  headerShade: {
    backgroundColor: colors.primaryDark,
    bottom: 0,
    opacity: 0.32,
    position: 'absolute',
    right: 0,
    top: 0,
    width: '42%',
  },
  headerTitle: {
    color: colors.textInverse,
    fontSize: 22,
    fontWeight: '700',
  },
  headerSubtitle: {
    color: colors.headerSubtitle,
    fontSize: 13,
    marginTop: 6,
  },
  container: {
    backgroundColor: colors.pageBg,
    padding: 16,
    paddingBottom: 28,
  },
  card: {
    backgroundColor: colors.cardBg,
    borderRadius: 14,
    elevation: 1,
    padding: 16,
    shadowColor: '#000000',
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.08,
    shadowRadius: 1,
  },
  cardWithTopMargin: {
    backgroundColor: colors.cardBg,
    borderRadius: 14,
    elevation: 1,
    marginTop: 12,
    padding: 16,
    shadowColor: '#000000',
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.08,
    shadowRadius: 1,
  },
  sectionTitle: {
    color: colors.textPrimary,
    fontSize: 16,
    fontWeight: '700',
  },
  sectionTitleFlex: {
    color: colors.textPrimary,
    flex: 1,
    fontSize: 16,
    fontWeight: '700',
  },
  description: {
    color: colors.textSecondary,
    fontSize: 13,
    marginTop: 6,
  },
  pushIdBox: {
    backgroundColor: colors.logBg,
    borderColor: colors.divider,
    borderRadius: 10,
    borderWidth: 1,
    color: colors.textPrimary,
    fontSize: 15,
    lineHeight: 21,
    marginTop: 14,
    minHeight: 72,
    padding: 12,
  },
  statusRow: {
    alignItems: 'center',
    flexDirection: 'row',
    marginTop: 12,
  },
  statusDot: {
    borderRadius: 4,
    height: 8,
    marginRight: 8,
    width: 8,
  },
  statusText: {
    flex: 1,
    fontSize: 13,
  },
  buttonRow: {
    flexDirection: 'row',
    marginTop: 14,
  },
  buttonSpace: {
    width: 12,
  },
  buttonBase: {
    alignItems: 'center',
    borderRadius: 10,
    justifyContent: 'center',
    minHeight: 44,
    paddingHorizontal: 10,
  },
  flexButton: {
    flex: 1,
  },
  fullWidthButton: {
    marginTop: 12,
    width: '100%',
  },
  primaryButton: {
    backgroundColor: colors.primary,
  },
  secondaryButton: {
    backgroundColor: colors.cardBg,
    borderColor: colors.primary,
    borderWidth: 1,
  },
  buttonText: {
    fontSize: 14,
    fontWeight: '500',
  },
  primaryButtonText: {
    color: colors.textInverse,
  },
  secondaryButtonText: {
    color: colors.primary,
  },
  input: {
    backgroundColor: colors.cardBg,
    borderColor: colors.divider,
    borderRadius: 10,
    borderWidth: 1,
    color: colors.textPrimary,
    fontSize: 14,
    height: 46,
    marginTop: 14,
    paddingHorizontal: 12,
  },
  resultHeader: {
    alignItems: 'center',
    flexDirection: 'row',
  },
  clearButton: {
    alignItems: 'center',
    height: 32,
    justifyContent: 'center',
    minWidth: 44,
  },
  clearButtonText: {
    color: colors.textSecondary,
    fontSize: 13,
  },
  resultBox: {
    backgroundColor: colors.logBg,
    borderColor: colors.divider,
    borderRadius: 10,
    borderWidth: 1,
    color: colors.textPrimary,
    fontSize: 13,
    lineHeight: 19,
    marginTop: 10,
    minHeight: 56,
    padding: 12,
  },
});

export default App;
