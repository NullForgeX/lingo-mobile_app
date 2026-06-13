import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/curriculum_bloc.dart';

class UnitsScreen extends StatefulWidget {
  final String languageId;

  const UnitsScreen({super.key, required this.languageId});

  @override
  State<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CurriculumBloc>().add(LoadUnitsEvent(widget.languageId));
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Widget _buildDownloadIndicator(
    BuildContext context,
    String unitId,
    bool isDownloaded,
    bool isDownloading,
  ) {
    if (isDownloading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryLight),
        ),
      );
    } else if (isDownloaded) {
      return const Icon(
        Icons.check_circle_rounded,
        color: Colors.green,
        size: 28,
      );
    } else {
      return IconButton(
        icon: const Icon(
          Icons.cloud_download_outlined,
          color: AppColors.secondaryLight,
          size: 26,
        ),
        onPressed: () {
          context.read<CurriculumBloc>().add(DownloadUnitEvent(unitId));
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Units'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home');
          },
        ),
      ),
      body: BlocConsumer<CurriculumBloc, CurriculumState>(
        listener: (context, state) {
          if (state is UnitsLoaded && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: AppColors.errorLight,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CurriculumLoading || state is CurriculumInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CurriculumError) {
            return Center(child: Text(state.message));
          } else if (state is UnitsLoaded) {
            final units = state.units;
            final downloadedUnitIds = state.downloadedUnitIds;
            final downloadingUnitIds = state.downloadingUnitIds;

            if (units.isEmpty) {
              return const Center(child: Text('No units available for this language.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: units.length,
              itemBuilder: (context, index) {
                final unit = units[index];
                final order = unit['order'] ?? 0;
                final title = unit['title'] ?? '';
                final summary = unit['summary'] ?? '';
                final unitId = unit['id'] ?? '';
                final isDownloaded = downloadedUnitIds.contains(unitId);
                final isDownloading = downloadingUnitIds.contains(unitId);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 3,
                  child: InkWell(
                    onTap: () async {
                      if (isDownloaded) {
                        context.push('/units/${widget.languageId}/lessons/$unitId');
                      } else {
                        final router = GoRouter.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        final isOnline = await _checkInternetConnection();
                        if (!mounted) return;
                        if (isOnline) {
                          router.push('/units/${widget.languageId}/lessons/$unitId');
                        } else {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('This unit is not downloaded for offline use. Connect to the internet to download it.'),
                              backgroundColor: AppColors.errorLight,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      color: Theme.of(context).cardColor,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryLight.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${order + 1}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondaryLight,
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimaryLight,
                                      ),
                                ),
                                if (summary.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    summary,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondaryLight,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Align(
                            alignment: Alignment.center,
                            child: _buildDownloadIndicator(
                              context,
                              unitId,
                              isDownloaded,
                              isDownloading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
