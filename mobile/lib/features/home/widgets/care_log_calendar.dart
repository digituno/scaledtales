import 'package:flutter/material.dart';

import '../../../core/enums/enums.dart';
import '../../care_log/models/care_log_model.dart';
import '../../care_log/widgets/care_log_card.dart';

/// 홈스크린에 표시되는 월별 케어로그 달력 위젯.
///
/// - 현재 월을 기본으로 표시하며 < > 버튼으로 월 이동 가능
/// - 일지가 등록된 날짜에 대표 LogType 색상 원(●) 표시
/// - 1건 초과 시 원 옆에 "+" 마크 추가
/// - 날짜 탭 시 해당 일자의 전체 일지를 바텀시트로 표시
class CareLogCalendar extends StatefulWidget {
  final List<CareLog> careLogs;

  const CareLogCalendar({super.key, required this.careLogs});

  @override
  State<CareLogCalendar> createState() => _CareLogCalendarState();
}

class _CareLogCalendarState extends State<CareLogCalendar> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
  }

  /// 날짜 키('YYYY-MM-DD') 기준으로 일지를 그룹핑
  Map<String, List<CareLog>> get _groupedByDate {
    final map = <String, List<CareLog>>{};
    for (final log in widget.careLogs) {
      if (log.logDate.length >= 10) {
        final key = log.logDate.substring(0, 10);
        map.putIfAbsent(key, () => []).add(log);
      }
    }
    return map;
  }

  /// LogType → 색상 매핑 (CareLogCard와 동일)
  static Color _logTypeColor(LogType type) => switch (type) {
        LogType.feeding => Colors.orange,
        LogType.shedding => Colors.teal,
        LogType.defecation => Colors.brown,
        LogType.mating => Colors.pink,
        LogType.eggLaying => Colors.amber,
        LogType.candling => Colors.indigo,
        LogType.hatching => Colors.green,
      };

  void _goToPrevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  /// 해당 날짜의 전체 일지를 바텀시트로 표시
  void _showDayLogs(
      BuildContext context, DateTime date, List<CareLog> logs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 드래그 핸들
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            // 날짜 헤더
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                '${date.year}년 ${date.month}월 ${date.day}일 일지',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const Divider(height: 1),
            // 일지 목록
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 8),
                itemCount: logs.length,
                itemBuilder: (_, i) => CareLogCard(
                  careLog: logs[i],
                  showAnimalName: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grouped = _groupedByDate;

    // 달력 그리드 계산
    final firstDay =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    // Dart weekday: 1=월 ... 7=일. 일요일 우선(index 0) → 오프셋 = weekday % 7
    final offset = firstDay.weekday % 7;
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    // 7의 배수로 올림
    final totalCells = ((offset + daysInMonth) / 7).ceil() * 7;

    final today = DateTime.now();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
        child: Column(
          children: [
            // 헤더: < 2026년 2월 >
            _buildHeader(theme),
            const SizedBox(height: 6),
            // 요일 행: 일 월 화 수 목 금 토
            _buildWeekdayRow(theme),
            const SizedBox(height: 4),
            // 날짜 셀 그리드
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.9,
              ),
              itemCount: totalCells,
              itemBuilder: (context, index) {
                final dayNum = index - offset + 1;
                final isCurrentMonth =
                    dayNum >= 1 && dayNum <= daysInMonth;

                DateTime? cellDate;
                if (isCurrentMonth) {
                  cellDate = DateTime(
                      _currentMonth.year, _currentMonth.month, dayNum);
                }

                // 요일별 색상 (일=빨강, 토=파랑)
                final col = index % 7;
                Color dayTextColor;
                if (!isCurrentMonth) {
                  dayTextColor =
                      theme.colorScheme.onSurface.withOpacity(0.25);
                } else if (col == 0) {
                  dayTextColor = Colors.red;
                } else if (col == 6) {
                  dayTextColor = Colors.blue;
                } else {
                  dayTextColor = theme.colorScheme.onSurface;
                }

                // 오늘 여부
                final isToday = isCurrentMonth &&
                    cellDate != null &&
                    cellDate.year == today.year &&
                    cellDate.month == today.month &&
                    cellDate.day == today.day;

                // 해당 날짜 일지 목록
                List<CareLog> logsForDay = [];
                if (isCurrentMonth && cellDate != null) {
                  final dateKey =
                      '${cellDate.year}-${cellDate.month.toString().padLeft(2, '0')}-${cellDate.day.toString().padLeft(2, '0')}';
                  logsForDay = grouped[dateKey] ?? [];
                }

                return _buildDayCell(
                  context,
                  theme,
                  dayNum: dayNum,
                  isCurrentMonth: isCurrentMonth,
                  isToday: isToday,
                  dayTextColor: dayTextColor,
                  logsForDay: logsForDay,
                  cellDate: cellDate,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _goToPrevMonth,
          visualDensity: VisualDensity.compact,
        ),
        Text(
          '${_currentMonth.year}년 ${_currentMonth.month}월',
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _goToNextMonth,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildWeekdayRow(ThemeData theme) {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      children: List.generate(7, (i) {
        final color = i == 0
            ? Colors.red
            : i == 6
                ? Colors.blue
                : theme.colorScheme.onSurfaceVariant;
        return Expanded(
          child: Center(
            child: Text(
              weekdays[i],
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    ThemeData theme, {
    required int dayNum,
    required bool isCurrentMonth,
    required bool isToday,
    required Color dayTextColor,
    required List<CareLog> logsForDay,
    required DateTime? cellDate,
  }) {
    final hasLogs = logsForDay.isNotEmpty;
    final hasMore = logsForDay.length > 1;

    // 로그 인디케이터 (색상 원 + "+" 마크)
    Widget indicator = const SizedBox(height: 9);
    if (hasLogs) {
      final repColor =
          _logTypeColor(LogType.fromValue(logsForDay.first.logType));
      indicator = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: repColor,
              shape: BoxShape.circle,
            ),
          ),
          if (hasMore)
            Text(
              '+',
              style: TextStyle(
                fontSize: 8,
                color: repColor,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
        ],
      );
    }

    // 날짜 숫자 (오늘은 원형 배경)
    final dayLabel = isCurrentMonth ? '$dayNum' : '';
    final dayWidget = isToday
        ? Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                dayLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        : SizedBox(
            height: 24,
            child: Center(
              child: Text(
                dayLabel,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: dayTextColor),
              ),
            ),
          );

    final cellContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        dayWidget,
        const SizedBox(height: 2),
        indicator,
      ],
    );

    // 일지가 있으면 탭 가능하게 처리
    if (hasLogs && cellDate != null) {
      return InkWell(
        onTap: () => _showDayLogs(context, cellDate, logsForDay),
        borderRadius: BorderRadius.circular(6),
        child: cellContent,
      );
    }
    return cellContent;
  }
}
