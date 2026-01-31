import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final String query;
  final List<int> filteredSurahs; // أرقام السور بعد التصفية
  final int tabIndex; // 0: سور، 1: أجزاء، 2: أحزاب

  const HomeState({this.query = '', this.filteredSurahs = const [], this.tabIndex = 0});

  HomeState copyWith({String? query, List<int>? filteredSurahs, int? tabIndex}) => HomeState(
        query: query ?? this.query,
        filteredSurahs: filteredSurahs ?? this.filteredSurahs,
        tabIndex: tabIndex ?? this.tabIndex,
      );

  @override
  List<Object?> get props => [query, filteredSurahs, tabIndex];
}
