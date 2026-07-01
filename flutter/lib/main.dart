import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_push/tencent_cloud_chat_push.dart';

const int sdkAppId = 0;
const String appKey = '';
const int apnsCertificateId = 11111;
const String customRegistrationIdKey = 'timpush_custom_registration_id';

String registrationIdFromPushResultData(Object? data) {
  if (data is String) {
    return data.trim();
  }
  if (data is Map) {
    final value = data['registrationID'] ?? data['registrationId'] ?? data['RegistrationID'];
    return value?.toString().trim() ?? '';
  }
  return data?.toString().trim() ?? '';
}

void main() {
  runApp(const PushDemoApp());
}

class PushDemoApp extends StatelessWidget {
  const PushDemoApp({super.key, this.autoRegister = true});

  final bool autoRegister;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PushDemoPage(autoRegister: autoRegister),
    );
  }
}

class PushDemoPage extends StatefulWidget {
  const PushDemoPage({super.key, this.autoRegister = true});

  final bool autoRegister;

  @override
  State<PushDemoPage> createState() => _PushDemoPageState();
}

class _PushDemoPageState extends State<PushDemoPage> {
  static const String emptyValue = '正在获取...';
  static const String resultEmpty = '暂无结果';

  final TencentCloudChatPush _push = TencentCloudChatPush();
  final TextEditingController _registrationController = TextEditingController();

  String _registrationId = emptyValue;
  String _registerState = '未注册';
  Color _registerStateColor = const Color(0xFF98A2B3);
  String _result = resultEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.autoRegister) {
      _registerWithPersistedId(showSnackBar: false);
    }
  }

  @override
  void dispose() {
    _registrationController.dispose();
    super.dispose();
  }

  // 统一注册入口：注册前先把"正确的 ID"写入 SDK 内存（自定义值或空串清空），再 registerPush。
  // setRegistrationID 必须在 registerPush 之前调用才会生效。
  Future<void> _registerWithPersistedId({required bool showSnackBar}) async {
    setState(() {
      _registerState = '注册中';
      _registerStateColor = const Color(0xFFFF8A00);
      _result = '注册推送\n正在注册...';
    });

    final customId = await _readCustomRegistrationId();
    // 有自定义值则用自定义值；无则用空串清空 SDK 内存里的残留，让其回退默认 ID
    await _push.setRegistrationID(registrationID: customId.isNotEmpty ? customId : '');
    if (!mounted) {
      return;
    }
    await _doRegisterPush(showSnackBar: showSnackBar);
  }

  // 实际执行 registerPush，成功后通过 getRegistrationID 刷新展示真实生效的 ID
  Future<void> _doRegisterPush({required bool showSnackBar}) async {
    final result = await _push.registerPush(
      sdkAppId: sdkAppId,
      appKey: appKey,
      apnsCertificateID: apnsCertificateId,
      onNotificationClicked: ({required String ext, String? userID, String? groupID}) {
        _showResult('通知点击', ext);
      },
    );

    if (!mounted) {
      return;
    }

    if (result.code == 0) {
      if (showSnackBar) {
        _showSnackBar('registerPush success');
      }
      setState(() {
        _registerState = '已注册';
        _registerStateColor = const Color(0xFF00A870);
        _result = '注册成功\n正在获取 RegistrationID...';
      });
      await _refreshRegistrationId(title: '注册成功');
    } else {
      setState(() {
        _registerState = '注册失败';
        _registerStateColor = const Color(0xFFE34D59);
        _result = '注册失败\ncode=${result.code}, msg=${result.errorMessage ?? ''}';
      });
      if (showSnackBar) {
        _showSnackBar('registerPush error code=${result.code}');
      }
    }
  }

  Future<void> _unregisterPush() async {
    _showResult('注销推送', '正在注销...');
    final result = await _push.unRegisterPush();
    if (!mounted) {
      return;
    }
    if (result.code == 0) {
      _showSnackBar('unRegisterPush success');
      setState(() {
        _registerState = '未注册';
        _registerStateColor = const Color(0xFF98A2B3);
        _registrationId = emptyValue;
        _result = '注销成功\n推送注册已注销';
      });
    } else {
      _showResult('注销失败', 'code=${result.code}, msg=${result.errorMessage ?? ''}');
    }
  }

  Future<void> _refreshRegistrationId({String title = '获取成功'}) async {
    _showResult('刷新 RegistrationID', '正在获取...');
    final result = await _push.getRegistrationID();
    if (!mounted) {
      return;
    }
    if (result.code != 0) {
      setState(() {
        _registrationId = '暂无推送 ID';
        _result = '$title\n获取 RegistrationID 失败：code=${result.code}, msg=${result.errorMessage ?? ''}';
      });
      return;
    }
    final value = registrationIdFromPushResultData(result.data);
    setState(() {
      _registrationId = value.isEmpty ? '暂无推送 ID' : value;
      _result = value.isEmpty ? '$title\nRegistrationID 为空，请稍后刷新' : '$title\nRegistrationID: $value';
    });
  }

  Future<void> _setRegistrationId() async {
    final value = _registrationController.text.trim();
    if (value.isEmpty) {
      _showSnackBar('registrationId is null');
      _showResult('设置失败', 'RegistrationID 不能为空');
      return;
    }

    _showResult('设置 RegistrationID', '正在设置...');
    // 先持久化，再走统一注册入口（注册前会把该自定义 ID 设入 SDK 并重新注册使其生效）
    await _saveCustomRegistrationId(value);
    if (!mounted) {
      return;
    }
    _showSnackBar('setRegistrationId success');
    _showResult('设置成功', '已持久化，正在重新注册以使自定义推送 ID 生效...');
    await _registerWithPersistedId(showSnackBar: false);
  }

  // 重置默认 ID：清除本地持久化并重新注册，恢复 SDK 默认生成的推送 ID
  // 重置默认 ID：清除 Demo 持久化 → 显式 set 空串清掉 SDK 缓存 → 反注册，回到未注册态
  Future<void> _resetRegistrationId() async {
    await _clearCustomRegistrationId();
    if (!mounted) {
      return;
    }
    _showResult('重置默认 ID', '正在清除自定义推送 ID 并反注册...');
    // SDK 内部也缓存了 RegistrationID，先 set 空串清掉
    await _push.setRegistrationID(registrationID: '');
    if (!mounted) {
      return;
    }
    // 反注册，清除当前登录态/token
    final result = await _push.unRegisterPush();
    if (!mounted) {
      return;
    }
    if (result.code == 0) {
      _showSnackBar('已重置为 SDK 默认推送 ID');
      setState(() {
        _registerState = '未注册';
        _registerStateColor = const Color(0xFF98A2B3);
        _registrationId = emptyValue;
        _result = '重置成功\n已清除自定义推送 ID 并反注册，重新注册或下次启动将使用默认 ID';
      });
    } else {
      _showResult('重置失败', '反注册失败 code=${result.code}, msg=${result.errorMessage ?? ''}');
    }
  }

  Future<String> _readCustomRegistrationId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(customRegistrationIdKey) ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> _saveCustomRegistrationId(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(customRegistrationIdKey, value);
    } catch (_) {
      // ignore persistence error in demo
    }
  }

  Future<void> _clearCustomRegistrationId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(customRegistrationIdKey);
    } catch (_) {
      // ignore persistence error in demo
    }
  }

  void _copyRegistrationId() {
    if (_registrationId == emptyValue || _registrationId.isEmpty) {
      _showSnackBar('RegistrationID is empty');
      return;
    }
    _showSnackBar('已复制');
    _showResult('复制成功', 'RegistrationID 已复制到剪贴板');
  }

  void _showResult(String title, [String? detail]) {
    setState(() {
      _result = detail == null || detail.isEmpty ? title : '$title\n$detail';
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('推送 ID'),
                          const SizedBox(height: 6),
                          const Text(
                            '将该 ID 填入控制台或服务端接口，即可向当前设备发送测试推送。',
                            style: TextStyle(color: Color(0xFF667085), fontSize: 13),
                          ),
                          const SizedBox(height: 14),
                          _BoxText(text: _registrationId, minHeight: 72, fontSize: 15),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: _registerStateColor, shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_registerState, style: TextStyle(color: _registerStateColor, fontSize: 13))),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(child: _Button(label: '复制', primary: true, onPressed: _copyRegistrationId)),
                              const SizedBox(width: 12),
                              Expanded(child: _Button(label: '刷新', onPressed: () => _refreshRegistrationId())),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('更多操作'),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _registrationController,
                            decoration: const InputDecoration(
                              hintText: '输入新的推送 ID',
                              hintStyle: TextStyle(color: Color(0xFF98A2B3)),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFFE5E8EF))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFFE5E8EF))),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _Button(label: '自定义推送 ID', onPressed: _setRegistrationId)),
                              const SizedBox(width: 12),
                              Expanded(child: _Button(label: '重置推送 ID', onPressed: _resetRegistrationId)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _Button(label: '重新注册', onPressed: () => _registerWithPersistedId(showSnackBar: true))),
                              const SizedBox(width: 12),
                              Expanded(child: _Button(label: '注销推送', onPressed: _unregisterPush)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Card(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(child: _SectionTitle('结果')),
                              TextButton(onPressed: () => setState(() => _result = resultEmpty), child: const Text('清空', style: TextStyle(color: Color(0xFF667085), fontSize: 13))),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _BoxText(text: _result, minHeight: 56, fontSize: 13),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF006EFF), Color(0xFF0047B3)]),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TIMPush Demo', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text('启动后自动注册，获取推送 ID 用于发送测试', style: TextStyle(color: Color(0xFFD7E8FF), fontSize: 13)),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 1, offset: Offset(0, 1))]),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16, fontWeight: FontWeight.bold));
}

class _BoxText extends StatelessWidget {
  const _BoxText({required this.text, required this.minHeight, required this.fontSize});
  final String text;
  final double minHeight;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border.all(color: const Color(0xFFE5E8EF)), borderRadius: BorderRadius.circular(10)),
      child: SelectableText(text, style: TextStyle(color: const Color(0xFF1F2937), fontSize: fontSize)),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({required this.label, required this.onPressed, this.primary = false});
  final String label;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: primary ? const Color(0xFF006EFF) : Colors.white,
          side: const BorderSide(color: Color(0xFF006EFF)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
        child: Text(label, style: TextStyle(color: primary ? Colors.white : const Color(0xFF006EFF), fontSize: 14)),
      ),
    );
  }
}
