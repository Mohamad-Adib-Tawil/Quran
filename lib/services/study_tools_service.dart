import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AyahTagType { review, hifz, tadabbur }

enum GoalMetric { ayahs, pages, listeningMinutes }

enum GoalPeriod { daily, weekly }

class AyahTagEntry {
  final int ayahUq;
  final int surah;
  final int ayah;
  final int page;
  final AyahTagType type;
  final int colorValue;
  final String? note;
  final DateTime createdAt;

  const AyahTagEntry({
    required this.ayahUq,
    required this.surah,
    required this.ayah,
    required this.page,
    required this.type,
    required this.colorValue,
    required this.createdAt,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'ayahUq': ayahUq,
        'surah': surah,
        'ayah': ayah,
        'page': page,
        'type': type.name,
        'colorValue': colorValue,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AyahTagEntry.fromJson(Map<String, dynamic> json) => AyahTagEntry(
        ayahUq: (json['ayahUq'] as num?)?.toInt() ?? -1,
        surah: (json['surah'] as num?)?.toInt() ?? 1,
        ayah: (json['ayah'] as num?)?.toInt() ?? 1,
        page: (json['page'] as num?)?.toInt() ?? 1,
        type: AyahTagType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => AyahTagType.review,
        ),
        colorValue:
            (json['colorValue'] as num?)?.toInt() ?? Colors.amber.value,
        note: json['note'] as String?,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class AyahNoteEntry {
  final String id;
  final int ayahUq;
  final int surah;
  final int ayah;
  final int page;
  final String text;
  final DateTime createdAt;

  const AyahNoteEntry({
    required this.id,
    required this.ayahUq,
    required this.surah,
    required this.ayah,
    required this.page,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ayahUq': ayahUq,
        'surah': surah,
        'ayah': ayah,
        'page': page,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AyahNoteEntry.fromJson(Map<String, dynamic> json) => AyahNoteEntry(
        id: (json['id'] as String?) ?? '',
        ayahUq: (json['ayahUq'] as num?)?.toInt() ?? -1,
        surah: (json['surah'] as num?)?.toInt() ?? 1,
        ayah: (json['ayah'] as num?)?.toInt() ?? 1,
        page: (json['page'] as num?)?.toInt() ?? 1,
        text: (json['text'] as String?) ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class GoalPlan {
  final GoalMetric metric;
  final GoalPeriod period;
  final int target;

  const GoalPlan({
    required this.metric,
    required this.period,
    required this.target,
  });

  Map<String, dynamic> toJson() => {
        'metric': metric.name,
        'period': period.name,
        'target': target,
      };

  factory GoalPlan.fromJson(Map<String, dynamic> json) => GoalPlan(
        metric: GoalMetric.values.firstWhere(
          (e) => e.name == json['metric'],
          orElse: () => GoalMetric.pages,
        ),
        period: GoalPeriod.values.firstWhere(
          (e) => e.name == json['period'],
          orElse: () => GoalPeriod.daily,
        ),
        target: (json['target'] as num?)?.toInt() ?? 0,
      );
}

class GoalProgressSnapshot {
  final GoalMetric metric;
  final GoalPeriod period;
  final int current;
  final int target;

  const GoalProgressSnapshot({
    required this.metric,
    required this.period,
    required this.current,
    required this.target,
  });

  double get ratio => target <= 0 ? 0 : (current / target).clamp(0.0, 1.0);
}

class StudyToolsService {
  static const _kTags = 'study_tags_v1';
  static const _kNotes = 'study_notes_v1';
  static const _kGoals = 'study_goals_v1';
  static const _kDailyStats = 'study_daily_stats_v1';
  static const _kWeeklyStats = 'study_weekly_stats_v1';

  final SharedPreferences _prefs;
  StudyToolsService(this._prefs);

  Future<void> upsertTag(AyahTagEntry entry) async {
    final map = _readJsonMap(_kTags);
    map['${entry.ayahUq}'] = entry.toJson();
    await _prefs.setString(_kTags, jsonEncode(map));
  }

  AyahTagEntry? getTagForAyah(int ayahUq) {
    final map = _readJsonMap(_kTags);
    final raw = map['$ayahUq'];
    if (raw is! Map<String, dynamic>) return null;
    return AyahTagEntry.fromJson(raw);
  }

  Future<void> removeTag(int ayahUq) async {
    final map = _readJsonMap(_kTags);
    map.remove('$ayahUq');
    await _prefs.setString(_kTags, jsonEncode(map));
  }

  Future<void> addNote(AyahNoteEntry entry) async {
    final list = _readJsonList(_kNotes);
    list.add(entry.toJson());
    await _prefs.setString(_kNotes, jsonEncode(list));
  }

  List<AyahNoteEntry> getNotesForAyah(int ayahUq) {
    final notes = _readJsonList(_kNotes)
        .map((e) => AyahNoteEntry.fromJson(e))
        .where((e) => e.ayahUq == ayahUq)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notes;
  }

  List<AyahNoteEntry> getRecentNotes({int limit = 20}) {
    final notes = _readJsonList(_kNotes).map((e) => AyahNoteEntry.fromJson(e)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notes.take(limit).toList();
  }

  List<AyahTagEntry> getAllTags() {
    final map = _readJsonMap(_kTags);
    final tags = map.values
        .whereType<Map<String, dynamic>>()
        .map(AyahTagEntry.fromJson)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tags;
  }

  Map<int, List<AyahNoteEntry>> getNotesGroupedBySurah() {
    final grouped = <int, List<AyahNoteEntry>>{};
    for (final note in getRecentNotes(limit: 100000)) {
      grouped.putIfAbsent(note.surah, () => <AyahNoteEntry>[]).add(note);
    }
    return grouped;
  }

  Future<void> setGoal(GoalPlan plan) async {
    final map = _readJsonMap(_kGoals);
    map[_goalKey(plan.metric, plan.period)] = plan.toJson();
    await _prefs.setString(_kGoals, jsonEncode(map));
  }

  List<GoalPlan> getGoals() {
    final map = _readJsonMap(_kGoals);
    return map.values
        .whereType<Map<String, dynamic>>()
        .map(GoalPlan.fromJson)
        .toList();
  }

  Future<void> trackPageRead(int pageNumber) async {
    await _trackIntSet(
      key: _kDailyStats,
      bucketId: _dayId(DateTime.now()),
      field: 'pages',
      value: pageNumber,
    );
    await _trackIntSet(
      key: _kWeeklyStats,
      bucketId: _weekId(DateTime.now()),
      field: 'pages',
      value: pageNumber,
    );
  }

  Future<void> trackAyahRead(int ayahUq) async {
    await _trackIntSet(
      key: _kDailyStats,
      bucketId: _dayId(DateTime.now()),
      field: 'ayahs',
      value: ayahUq,
    );
    await _trackIntSet(
      key: _kWeeklyStats,
      bucketId: _weekId(DateTime.now()),
      field: 'ayahs',
      value: ayahUq,
    );
  }

  Future<void> trackListeningSeconds(int seconds) async {
    await _incrementCounter(
      key: _kDailyStats,
      bucketId: _dayId(DateTime.now()),
      field: 'listenSec',
      delta: seconds,
    );
    await _incrementCounter(
      key: _kWeeklyStats,
      bucketId: _weekId(DateTime.now()),
      field: 'listenSec',
      delta: seconds,
    );
  }

  List<GoalProgressSnapshot> buildGoalProgress() {
    final goals = getGoals();
    final daily = _readBucket(_kDailyStats, _dayId(DateTime.now()));
    final weekly = _readBucket(_kWeeklyStats, _weekId(DateTime.now()));
    return goals.map((goal) {
      final bucket = goal.period == GoalPeriod.daily ? daily : weekly;
      final current = switch (goal.metric) {
        GoalMetric.pages => _intSetCount(bucket['pages']),
        GoalMetric.ayahs => _intSetCount(bucket['ayahs']),
        GoalMetric.listeningMinutes => (((bucket['listenSec'] as num?)?.toInt() ?? 0) / 60).floor(),
      };
      return GoalProgressSnapshot(
        metric: goal.metric,
        period: goal.period,
        current: current,
        target: goal.target,
      );
    }).toList();
  }

  String _goalKey(GoalMetric metric, GoalPeriod period) => '${metric.name}_${period.name}';

  Future<void> _trackIntSet({
    required String key,
    required String bucketId,
    required String field,
    required int value,
  }) async {
    final root = _readJsonMap(key);
    final bucket = _bucketMutable(root, bucketId);
    final current = ((bucket[field] as List?) ?? const [])
        .map((e) => (e as num).toInt())
        .toSet();
    current.add(value);
    bucket[field] = current.toList();
    root[bucketId] = bucket;
    await _prefs.setString(key, jsonEncode(root));
  }

  Future<void> _incrementCounter({
    required String key,
    required String bucketId,
    required String field,
    required int delta,
  }) async {
    final root = _readJsonMap(key);
    final bucket = _bucketMutable(root, bucketId);
    final current = (bucket[field] as num?)?.toInt() ?? 0;
    bucket[field] = current + delta;
    root[bucketId] = bucket;
    await _prefs.setString(key, jsonEncode(root));
  }

  Map<String, dynamic> _readBucket(String key, String bucketId) {
    final root = _readJsonMap(key);
    final bucket = root[bucketId];
    if (bucket is Map<String, dynamic>) return bucket;
    return {};
  }

  Map<String, dynamic> _bucketMutable(Map<String, dynamic> root, String bucketId) {
    final existing = root[bucketId];
    if (existing is Map<String, dynamic>) return Map<String, dynamic>.from(existing);
    return <String, dynamic>{};
  }

  int _intSetCount(dynamic raw) {
    if (raw is! List) return 0;
    return raw.map((e) => (e as num).toInt()).toSet().length;
  }

  Map<String, dynamic> _readJsonMap(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return <String, dynamic>{};
    return decoded.map((k, v) {
      if (v is Map) return MapEntry('$k', Map<String, dynamic>.from(v));
      return MapEntry('$k', v);
    });
  }

  List<Map<String, dynamic>> _readJsonList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return <Map<String, dynamic>>[];
    return decoded
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  String _dayId(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _weekId(DateTime dt) {
    final monday = dt.subtract(Duration(days: dt.weekday - 1));
    return _dayId(monday);
  }
}
