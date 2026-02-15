import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/constants/constants.dart';
import '../../../shared/widgets/layout/adaptive_app_header.dart';
import '../../../data/providers/admin/admin_config_provider.dart';

class AdminConfigScreen extends ConsumerStatefulWidget {
  const AdminConfigScreen({super.key});

  @override
  ConsumerState<AdminConfigScreen> createState() => _AdminConfigScreenState();
}

class _AdminConfigScreenState extends ConsumerState<AdminConfigScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _announcementController;
  late final TextEditingController _appVersionController;
  late final TextEditingController _maxDailyXPController;
  late final TextEditingController _heartRecoveryMinutesController;
  late final TextEditingController _maxHeartsController;

  bool _isSaving = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _announcementController = TextEditingController();
    _appVersionController = TextEditingController();
    _maxDailyXPController = TextEditingController();
    _heartRecoveryMinutesController = TextEditingController();
    _maxHeartsController = TextEditingController();
  }

  @override
  void dispose() {
    _announcementController.dispose();
    _appVersionController.dispose();
    _maxDailyXPController.dispose();
    _heartRecoveryMinutesController.dispose();
    _maxHeartsController.dispose();
    super.dispose();
  }

  void _loadConfigValues(Map<String, dynamic> config) {
    if (_isLoaded) return;
    _isLoaded = true;

    _announcementController.text = config['announcement']?.toString() ?? '';
    _appVersionController.text = config['appVersion']?.toString() ?? '';
    _maxDailyXPController.text = config['maxDailyXP']?.toString() ?? '';
    _heartRecoveryMinutesController.text =
        config['heartRecoveryMinutes']?.toString() ?? '';
    _maxHeartsController.text = config['maxHearts']?.toString() ?? '';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final notifier = ref.read(adminConfigNotifierProvider.notifier);

      final data = <String, dynamic>{
        'announcement': _announcementController.text.trim(),
        'appVersion': _appVersionController.text.trim(),
        'maxDailyXP':
            int.tryParse(_maxDailyXPController.text.trim()) ?? 0,
        'heartRecoveryMinutes':
            int.tryParse(_heartRecoveryMinutesController.text.trim()) ?? 0,
        'maxHearts':
            int.tryParse(_maxHeartsController.text.trim()) ?? 0,
      };

      await notifier.updateConfig(data);

      // Reset loaded flag so controllers update on next build
      _isLoaded = false;
      ref.invalidate(adminConfigProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정이 저장되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(adminConfigProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AdaptiveAppHeader(
              title: '앱 설정',
              gradientColors: AppColors.adminGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              titleAlignment: MainAxisAlignment.spaceBetween,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.headerText, size: 28),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            Expanded(
              child: configAsync.when(
                data: (config) {
                  _loadConfigValues(config);
                  return Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Announcement
                          _buildSectionLabel('공지사항'),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _announcementController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: '사용자에게 표시할 공지사항을 입력하세요',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // App Version
                          _buildSectionLabel('앱 버전'),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _appVersionController,
                            decoration: const InputDecoration(
                              hintText: '예: 1.0.0',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Max Daily XP
                          _buildSectionLabel('일일 최대 XP'),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _maxDailyXPController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              hintText: '예: 500',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            validator: (v) {
                              if (v != null && v.isNotEmpty) {
                                if (int.tryParse(v) == null) {
                                  return '숫자를 입력하세요';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Heart Recovery Minutes
                          _buildSectionLabel('하트 회복 시간(분)'),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _heartRecoveryMinutesController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              hintText: '예: 30',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            validator: (v) {
                              if (v != null && v.isNotEmpty) {
                                if (int.tryParse(v) == null) {
                                  return '숫자를 입력하세요';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Max Hearts
                          _buildSectionLabel('최대 하트 수'),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _maxHeartsController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              hintText: '예: 5',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            validator: (v) {
                              if (v != null && v.isNotEmpty) {
                                if (int.tryParse(v) == null) {
                                  return '숫자를 입력하세요';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // Save button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mathGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                                    )
                                  : const Text(
                                      '저장하기',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('설정 로드 실패: $e',
                          style: const TextStyle(color: AppColors.error)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(adminConfigProvider),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
