import 'package:flutter/material.dart';
import 'package:quran_app/core/di/service_locator.dart';
import 'package:quran_app/core/localization/app_localization_ext.dart';
import 'package:quran_app/core/theme/figma_typography.dart';
import 'package:quran_app/services/study_tools_service.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  late final StudyToolsService _service;

  @override
  void initState() {
    super.initState();
    _service = sl<StudyToolsService>();
  }

  Future<void> _editGoal(GoalMetric metric, GoalPeriod period) async {
    final t = context.tr;
    final c = TextEditingController();
    final target = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(t.goalsSetDialogTitle),
          content: TextField(
            controller: c,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: t.goalsSetDialogHint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(t.no),
            ),
            TextButton(
              onPressed: () {
                final value = int.tryParse(c.text.trim());
                Navigator.of(ctx).pop(value);
              },
              child: Text(t.save),
            ),
          ],
        );
      },
    );
    if (target == null || target <= 0) return;
    await _service.setGoal(
      GoalPlan(metric: metric, period: period, target: target),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final progress = _service.buildGoalProgress();
    return Scaffold(
      appBar: AppBar(title: Text(t.goalsPageTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            t.goalsTargetDailyWeeklyTitle,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _buildQuickSet(GoalMetric.ayahs, t.goalMetricAyahs),
          const SizedBox(height: 8),
          _buildQuickSet(GoalMetric.pages, t.goalMetricPages),
          const SizedBox(height: 8),
          _buildQuickSet(GoalMetric.listeningMinutes, t.goalMetricListeningMinutes),
          const SizedBox(height: 18),
          Text(
            t.goalsProgressReportTitle,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (progress.isEmpty)
            Text(
              t.goalsNoGoalsYet,
              style: FigmaTypography.caption12(color: Theme.of(context).hintColor),
            ),
          ...progress.map(_buildProgressTile),
        ],
      ),
    );
  }

  Widget _buildQuickSet(GoalMetric metric, String title) {
    final t = context.tr;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _editGoal(metric, GoalPeriod.daily),
                    child: Text(t.goalsDailyButton),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _editGoal(metric, GoalPeriod.weekly),
                    child: Text(t.goalsWeeklyButton),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTile(GoalProgressSnapshot item) {
    return Card(
      child: ListTile(
        title: Text('${_metricLabel(item.metric)} (${_periodLabel(item.period)})'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            LinearProgressIndicator(value: item.ratio),
            const SizedBox(height: 6),
            Text('${item.current} / ${item.target}'),
          ],
        ),
      ),
    );
  }

  String _metricLabel(GoalMetric m) {
    final t = context.tr;
    switch (m) {
      case GoalMetric.ayahs:
        return t.goalMetricAyahs;
      case GoalMetric.pages:
        return t.goalMetricPages;
      case GoalMetric.listeningMinutes:
        return t.goalMetricListeningMinutes;
    }
  }

  String _periodLabel(GoalPeriod p) {
    final t = context.tr;
    switch (p) {
      case GoalPeriod.daily:
        return t.goalPeriodDaily;
      case GoalPeriod.weekly:
        return t.goalPeriodWeekly;
    }
  }
}
