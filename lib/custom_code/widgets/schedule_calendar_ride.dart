// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:intl/intl.dart';
// Se quiser inicializar símbolos de data para locais exóticos, pode usar:
// import 'package:intl/date_symbol_data_local.dart' as intl_data;
import 'package:cloud_firestore/cloud_firestore.dart'; // DocumentReference

/// Fixed palette (dark + orange), matching the mockup.
class _CalColors {
  static const bg = Color(0xFF121316);
  static const card = Color(0xFF1A1B1F);
  static const sep = Color(0xFF202228);
  static const textPri = Color(0xFFE9EAEE);
  static const textSec = Color(0xFF8E939C);
  static const textMuted = Color(0xFF6C717A);

  static const dayIdle = Color(0xFF2A2D33);
  static const daySel = Color(0xFFFFA51F);
  static const daySelText = Color(0xFF101114);

  static const dot = Color(0xFFFFA51F);

  static const chipBg = Color(0xFF24272D);
  static const chipBorder = Color(0xFF30343B);
  static const chipText = textPri;
  static const chipTextMuted = textSec;
  static const chipSelBg = daySel;
  static const chipSelText = daySelText;
}

/// Period selector values.
enum _Period { morning, afternoon, evening }

/// Calendar + time-slot picker (robust vs.
///
/// null/locale).
class ScheduleCalendarRide extends StatefulWidget {
  const ScheduleCalendarRide({
    super.key,
    this.width,
    this.height,
    this.initialDate,
    this.orders,
    this.onSelected,
    this.widgetBelow,
    this.disableBookedSlots = false,
    this.use24hFormat = true,
    this.dateLocale = 'en_US',
    required this.openPage,

    // Back-compat aliases
    this.order,
    this.widgetAbaixo,
    this.abrirPage,
  });

  final double? width;
  final double? height;
  final DateTime? initialDate;

  /// Orders list to mark days/slots (assumes a DateTime? field named `dia`).
  final List<RideOrdersRecord>? orders;

  /// Fired when a slot is tapped (returns day+time).
  final Future<dynamic> Function(DateTime? date)? onSelected;

  /// Optional widget below (receives current selection: day-only if sem hora).
  final Widget Function(DateTime? date)? widgetBelow;

  /// If true, booked slots are disabled. Default: false.
  final bool disableBookedSlots;

  /// If true, renders time in 24h format. Default: true.
  final bool use24hFormat;

  /// Locale string. Prefer `pt_BR` / `en_US` (underscore).
  final String dateLocale;

  /// Navigation handler to open an existing order by ref.
  final Future<dynamic> Function(DocumentReference orderRef)? openPage;

  // Back-compat aliases
  final List<RideOrdersRecord>? order; // alias for orders
  final Widget Function(DateTime? date)? widgetAbaixo; // alias for widgetBelow
  final Future<dynamic> Function(DocumentReference orderRef)?
      abrirPage; // alias

  @override
  State<ScheduleCalendarRide> createState() => _ScheduleCalendarRideState();
}

class _ScheduleCalendarRideState extends State<ScheduleCalendarRide> {
  late DateTime _visibleMonth; // first day of the visible month
  DateTime? _selectedDate;
  _Period _selectedPeriod = _Period.morning;
  TimeOfDay? _selectedTime;

  /// Index by day (date-only) -> list of orders on that day.
  Map<DateTime, List<RideOrdersRecord>> _ordersByDay = {};

  // --- Locale helpers -------------------------------------------------------

  /// Normalize hyphen locales to underscore for `intl`.
  String get _normLocale {
    final s = (widget.dateLocale).trim();
    if (s.isEmpty) return 'en_US';
    return s.replaceAll('-', '_');
  }

  String _monthLabel(DateTime d) {
    try {
      return DateFormat('MMMM yyyy', _normLocale).format(d);
    } catch (_) {
      // Fallback em caso de locale esquisito
      return DateFormat('MMMM yyyy').format(d);
    }
  }

  List<String> get _weekdayLabels {
    try {
      final ds = DateFormat('', _normLocale).dateSymbols;
      // DateSymbols.NARROWWEEKDAYS começa no Domingo (index 0) para a maioria dos locais
      final labels = List<String>.from(ds.NARROWWEEKDAYS);
      // Garantir 7 items simples, letras maiúsculas
      return labels
          .map((e) => (e is String && e.isNotEmpty) ? e.toUpperCase() : '•')
          .toList();
    } catch (_) {
      return const ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    }
  }

  /// Format TimeOfDay sem depender de MaterialLocalizations (evita crash).
  String _fmtTime(TimeOfDay t) {
    if (widget.use24hFormat) {
      final hh = t.hour.toString().padLeft(2, '0');
      final mm = t.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
    // 12h
    final dt = DateTime(2000, 1, 1, t.hour, t.minute);
    try {
      return DateFormat('h:mm a', _normLocale).format(dt);
    } catch (_) {
      return DateFormat('h:mm a').format(dt);
    }
  }

  // --------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    final now = widget.initialDate ?? DateTime.now();
    _visibleMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
    _rebuildOrderIndex();

    // Se quiser garantir símbolos de data para locais menos comuns:
    // intl_data.initializeDateFormatting(_normLocale).catchError((e) {
    //   debugPrint('intl init failed for $_normLocale: $e');
    // });
  }

  @override
  void didUpdateWidget(covariant ScheduleCalendarRide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orders != widget.orders || oldWidget.order != widget.order) {
      _rebuildOrderIndex();
      setState(() {});
    }
  }

  void _rebuildOrderIndex() {
    _ordersByDay = {};
    final list = widget.orders ?? widget.order ?? const <RideOrdersRecord>[];
    for (final o in list) {
      final DateTime? d = o.dia; // ajuste se seu campo tiver outro nome
      if (d == null) continue; // sem dia → não indexa (evita null crash)
      final key = DateTime(d.year, d.month, d.day);
      (_ordersByDay[key] ??= <RideOrdersRecord>[]).add(o);
    }
  }

  // ---------- helpers ----------
  RideOrdersRecord? _orderForSlot(DateTime day, TimeOfDay t) {
    final items = _ordersForDay(day);
    for (final o in items) {
      final dt = o.dia;
      if (dt == null) continue;
      if (dt.hour == t.hour && dt.minute == t.minute) {
        return o;
      }
    }
    return null;
  }

  DateTime _addMonths(DateTime d, int months) =>
      DateTime(d.year, d.month + months, 1);

  List<DateTime> _daysForGrid(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    // Grid começando no Domingo
    final start = first.subtract(Duration(days: first.weekday % 7));
    return List<DateTime>.generate(42, (i) => start.add(Duration(days: i)));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _hasOrderOn(DateTime d) =>
      (_ordersByDay[_dateOnly(d)]?.isNotEmpty ?? false);

  List<RideOrdersRecord> _ordersForDay(DateTime d) =>
      _ordersByDay[_dateOnly(d)] ?? const <RideOrdersRecord>[];

  List<TimeOfDay> _slotsFor(_Period p) {
    switch (p) {
      case _Period.morning:
        return const [
          TimeOfDay(hour: 7, minute: 0),
          TimeOfDay(hour: 7, minute: 30),
          TimeOfDay(hour: 8, minute: 0),
          TimeOfDay(hour: 8, minute: 30),
          TimeOfDay(hour: 9, minute: 0),
          TimeOfDay(hour: 9, minute: 30),
          TimeOfDay(hour: 10, minute: 0),
          TimeOfDay(hour: 10, minute: 30),
          TimeOfDay(hour: 11, minute: 0),
        ];
      case _Period.afternoon:
        return const [
          TimeOfDay(hour: 12, minute: 0),
          TimeOfDay(hour: 12, minute: 30),
          TimeOfDay(hour: 13, minute: 0),
          TimeOfDay(hour: 13, minute: 30),
          TimeOfDay(hour: 14, minute: 0),
          TimeOfDay(hour: 14, minute: 30),
          TimeOfDay(hour: 15, minute: 0),
          TimeOfDay(hour: 15, minute: 30),
          TimeOfDay(hour: 16, minute: 0),
        ];
      case _Period.evening:
        return const [
          TimeOfDay(hour: 17, minute: 0),
          TimeOfDay(hour: 17, minute: 30),
          TimeOfDay(hour: 18, minute: 0),
          TimeOfDay(hour: 18, minute: 30),
          TimeOfDay(hour: 19, minute: 0),
          TimeOfDay(hour: 19, minute: 30),
          TimeOfDay(hour: 20, minute: 0),
        ];
    }
  }

  DateTime _merge(DateTime d, TimeOfDay t) =>
      DateTime(d.year, d.month, d.day, t.hour, t.minute);

  DateTime? _currentSelection() {
    if (_selectedDate == null) return null;
    if (_selectedTime == null) {
      return DateTime(
          _selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
    }
    return _merge(_selectedDate!, _selectedTime!);
  }

  bool _isPastDay(DateTime day) {
    final now = DateTime.now();
    final d = DateTime(day.year, day.month, day.day);
    final today = DateTime(now.year, now.month, now.day);
    return d.isBefore(today);
  }

  bool _isPastSlot(DateTime day, TimeOfDay t) {
    final now = DateTime.now();
    final slot = _merge(day, t);
    return slot.isBefore(now);
  }

  bool _isSlotBooked(DateTime day, TimeOfDay t) =>
      _orderForSlot(day, t) != null;

  // ---------- UI ----------
  Widget _buildHeader(BuildContext context) {
    final prevMonth = _addMonths(_visibleMonth, -1);
    final nextMonth = _addMonths(_visibleMonth, 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _navButton(
          Icons.chevron_left_rounded,
          onTap: () => setState(() => _visibleMonth = prevMonth),
        ),
        Text(
          _monthLabel(_visibleMonth),
          style: const TextStyle(
            color: _CalColors.textPri,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        _navButton(
          Icons.chevron_right_rounded,
          onTap: () => setState(() => _visibleMonth = nextMonth),
        ),
      ],
    );
  }

  Widget _navButton(IconData icon, {VoidCallback? onTap}) {
    return InkResponse(
      onTap: onTap,
      radius: 20,
      child: Icon(icon, color: _CalColors.textSec, size: 24),
    );
  }

  Widget _buildWeekdayLabels() {
    final days = _weekdayLabels; // localizados
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days
            .map((d) => SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(
                        color: _CalColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final items = _daysForGrid(_visibleMonth);

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 6),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 44,
      ),
      itemBuilder: (context, i) {
        final day = items[i];
        final inMonth = day.month == _visibleMonth.month;
        final isToday = _isSameDay(day, DateTime.now());
        final isSelected =
            _selectedDate != null && _isSameDay(day, _selectedDate!);
        final disabled = _isPastDay(day);

        final baseTextColor = inMonth
            ? _CalColors.textPri
            : _CalColors.textMuted.withOpacity(0.6);
        final fg = isSelected
            ? _CalColors.daySelText
            : (disabled
                ? _CalColors.textMuted.withOpacity(0.5)
                : baseTextColor);
        final bg = isSelected
            ? _CalColors.daySel
            : (disabled
                ? _CalColors.dayIdle.withOpacity(0.25)
                : _CalColors.dayIdle);

        return GestureDetector(
          onTap: disabled
              ? null
              : () {
                  setState(() {
                    _selectedDate = day;
                    _selectedTime = null; // mudar o dia reseta a hora
                  });
                },
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: inMonth ? bg : _CalColors.dayIdle.withOpacity(0.35),
                    shape: BoxShape.circle,
                    border: (!isSelected && isToday)
                        ? Border.all(color: _CalColors.daySel, width: 1)
                        : null,
                  ),
                ),
                Text(
                  '${day.day}',
                  style: TextStyle(
                    color: fg,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (inMonth && _hasOrderOn(day))
                  Positioned(
                    bottom: -1,
                    child: Opacity(
                      opacity: disabled ? 0.4 : 1,
                      child: Container(
                        width: 5.5,
                        height: 5.5,
                        decoration: const BoxDecoration(
                          color: _CalColors.dot,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _periodChip(String label, _Period p) {
    final sel = _selectedPeriod == p;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: sel ? _CalColors.chipSelText : _CalColors.chipText,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
        selected: sel,
        onSelected: (_) => setState(() {
          _selectedPeriod = p;
          _selectedTime = null;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: sel ? Colors.transparent : _CalColors.chipBorder,
          ),
        ),
        backgroundColor: _CalColors.chipBg,
        selectedColor: _CalColors.chipSelBg,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        _periodChip('Morning', _Period.morning),
        _periodChip('Afternoon', _Period.afternoon),
        _periodChip('Evening', _Period.evening),
      ],
    );
  }

  Widget _buildTimeChips(BuildContext context) {
    if (_selectedDate == null) return const SizedBox.shrink();
    final day = _selectedDate!;
    final slots = _slotsFor(_selectedPeriod);

    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: [
        for (final t in slots)
          Builder(builder: (ctx) {
            final isBooked = _isSlotBooked(day, t);
            final isPast = _isPastSlot(day, t);
            final disabled = isPast || (widget.disableBookedSlots && isBooked);
            final selected = _selectedTime == t;

            Color bg = selected ? _CalColors.chipSelBg : _CalColors.chipBg;
            Color border =
                selected ? Colors.transparent : _CalColors.chipBorder;
            Color text =
                selected ? _CalColors.chipSelText : _CalColors.chipText;

            // Visual hint para horários já reservados
            if (isBooked && !selected) {
              border = _CalColors.daySel; // contorno laranja
            }
            if (disabled) {
              bg = bg.withOpacity(0.45);
              text = _CalColors.textMuted;
            }

            return InkWell(
              onTap: disabled
                  ? null
                  : () async {
                      setState(() => _selectedTime = t);
                      final dt = _merge(day, t);

                      if (widget.onSelected != null) {
                        await widget.onSelected!(dt);
                      }

                      final matched = _orderForSlot(day, t);
                      final open = widget.openPage ?? widget.abrirPage;
                      if (matched != null && open != null) {
                        try {
                          await open(matched.reference);
                        } catch (e) {
                          debugPrint('Error opening order page: $e');
                        }
                      }
                    },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                child: Text(
                  _fmtTime(t),
                  style: TextStyle(
                    color: text,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildSelectedDayOrdersCard() {
    if (_selectedDate == null) return const SizedBox.shrink();
    final items = _ordersForDay(_selectedDate!);
    if (items.isEmpty) return const SizedBox.shrink();

    String dateLabel;
    try {
      dateLabel = DateFormat('EEE, MMM d', _normLocale).format(_selectedDate!);
    } catch (_) {
      dateLabel = DateFormat('EEE, MMM d').format(_selectedDate!);
    }

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _CalColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _CalColors.sep),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Orders on $dateLabel',
            style: const TextStyle(
              color: _CalColors.textPri,
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((o) {
            final dt = o.dia;
            String timeStr;
            if (dt == null) {
              timeStr = 'Sem horário';
            } else if (widget.use24hFormat) {
              timeStr = DateFormat('HH:mm', _normLocale).format(dt);
            } else {
              timeStr = DateFormat('h:mm a', _normLocale).format(dt);
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.event, size: 18, color: _CalColors.textSec),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Order • $timeStr',
                      style: const TextStyle(
                        color: _CalColors.textPri,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selection = _currentSelection();

    return Container(
      width: widget.width ?? double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _CalColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: _CalColors.textPri),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const SizedBox(height: 4),
            _buildWeekdayLabels(),
            _buildCalendarGrid(),
            _buildSelectedDayOrdersCard(),
            const SizedBox(height: 8),
            _buildPeriodSelector(),
            const SizedBox(height: 12),
            _buildTimeChips(context),

            // Optional custom content below (form, notes, etc.)
            if ((widget.widgetBelow ?? widget.widgetAbaixo) != null) ...[
              const SizedBox(height: 12),
              (widget.widgetBelow ?? widget.widgetAbaixo)!(selection),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Back-compat class name (typo preserved).
// ---------------------------------------------------------------------------
class ScheduleCaledarRide extends ScheduleCalendarRide {
  const ScheduleCaledarRide({
    super.key,
    double? width,
    double? height,
    DateTime? initialDate,
    List<RideOrdersRecord>? order,
    List<RideOrdersRecord>? orders,
    Future<dynamic> Function(DateTime? date)? onSelected,
    Widget Function(DateTime? date)? widgetAbaixo,
    Widget Function(DateTime? date)? widgetBelow,
    bool disableBookedSlots = false,
    bool use24hFormat = true,
    String dateLocale = 'en_US',
    Future<dynamic> Function(DocumentReference orderRef)? abrirPage,
    Future<dynamic> Function(DocumentReference orderRef)? openPage,
  }) : super(
          width: width,
          height: height,
          initialDate: initialDate,
          order: order,
          orders: orders,
          onSelected: onSelected,
          widgetAbaixo: widgetAbaixo,
          widgetBelow: widgetBelow,
          disableBookedSlots: disableBookedSlots,
          use24hFormat: use24hFormat,
          dateLocale: dateLocale,
          abrirPage: abrirPage,
          openPage: openPage,
        );
}
