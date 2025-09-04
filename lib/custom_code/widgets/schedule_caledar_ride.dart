// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // DocumentReference

/// Paleta fixa (dark + laranja).
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

/// calendário “igual do print”
class ScheduleCaledarRide extends StatefulWidget {
  const ScheduleCaledarRide({
    super.key,
    this.width,
    this.height, // ignorado p/ altura fluida
    this.initialDate,

    /// Lista de pedidos para marcar dias com ponto (assume campo DateTime? `dia`).
    this.order,

    /// Callback ao escolher horário: devolve o DateTime (dia+hora).
    this.onSelected,

    /// OBRIGATÓRIO: abre página passando o DocumentReference do pedido existente.
    required this.abrirPage,
  });

  final double? width;
  final double? height; // não usamos p/ manter “infinito”
  final DateTime? initialDate;

  /// Pedidos (RideOrdersRecord) vindos do Firestore (FF).
  final List<RideOrdersRecord>? order;

  /// Callback de seleção (sem botão confirmar).
  final Future Function(DateTime? date)? onSelected;

  /// Navegação: exige DocumentReference do pedido.
  final Future Function(DocumentReference orderRef) abrirPage;

  @override
  State<ScheduleCaledarRide> createState() => _ScheduleCaledarRideState();
}

enum _Period { morning, afternoon, evening }

class _ScheduleCaledarRideState extends State<ScheduleCaledarRide> {
  late DateTime _visibleMonth; // 1º dia do mês visível
  DateTime? _selectedDate;
  _Period _selectedPeriod = _Period.morning;
  TimeOfDay? _selectedTime;

  /// Índice por dia (data-only) -> lista de orders nesse dia.
  Map<DateTime, List<RideOrdersRecord>> _ordersByDay = {};

  @override
  void initState() {
    super.initState();
    final now = widget.initialDate ?? DateTime.now();
    _visibleMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
    _rebuildOrderIndex();
  }

  @override
  void didUpdateWidget(covariant ScheduleCaledarRide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order != widget.order) {
      _rebuildOrderIndex();
      setState(() {});
    }
  }

  void _rebuildOrderIndex() {
    _ordersByDay = {};
    final list = widget.order ?? const <RideOrdersRecord>[];
    for (final o in list) {
      final DateTime? d = o.dia; // <-- ajuste se seu campo tiver outro nome
      if (d == null) continue;
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

  String _monthLabel(DateTime d) => DateFormat('MMMM yyyy').format(d);

  List<DateTime> _daysForGrid(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final start = first.subtract(Duration(days: first.weekday % 7)); // dom
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

  String _fmt(BuildContext ctx, TimeOfDay t) => MaterialLocalizations.of(ctx)
      .formatTimeOfDay(t, alwaysUse24HourFormat: false);

  DateTime _merge(DateTime d, TimeOfDay t) =>
      DateTime(d.year, d.month, d.day, t.hour, t.minute);

  // ---------- UI ----------
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _navButton(
          Icons.chevron_left_rounded,
          onTap: () =>
              setState(() => _visibleMonth = _addMonths(_visibleMonth, -1)),
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
          onTap: () =>
              setState(() => _visibleMonth = _addMonths(_visibleMonth, 1)),
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
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
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
    final today = DateTime.now();

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
        final isToday =
            _isSameDay(day, DateTime(today.year, today.month, today.day));
        final isSelected =
            _selectedDate != null && _isSameDay(day, _selectedDate!);

        final baseTextColor = inMonth
            ? _CalColors.textPri
            : _CalColors.textMuted.withOpacity(0.6);
        final fg = isSelected ? _CalColors.daySelText : baseTextColor;
        final bg = isSelected ? _CalColors.daySel : _CalColors.dayIdle;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = day;
              _selectedTime = null; // mudou o dia, zera a hora
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
                    child: Container(
                      width: 5.5,
                      height: 5.5,
                      decoration: const BoxDecoration(
                        color: _CalColors.dot,
                        shape: BoxShape.circle,
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
    final slots = _slotsFor(_selectedPeriod);
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: [
        for (final t in slots)
          InkWell(
            onTap: () async {
              setState(() => _selectedTime = t);
              final dt =
                  (_selectedDate != null) ? _merge(_selectedDate!, t) : null;

              // dispara callback de seleção (se tiver)
              if (widget.onSelected != null) {
                await widget.onSelected!(dt);
              }

              // se existir pedido exatamente neste horário, abre página com o ref
              if (_selectedDate != null) {
                final matched = _orderForSlot(_selectedDate!, t);
                if (matched != null) {
                  try {
                    await widget.abrirPage(matched.reference);
                  } catch (e) {
                    debugPrint('Erro ao abrir página: $e');
                  }
                } else {
                  // não há pedido neste horário -> nada a fazer aqui
                  // (se quiser criar e depois navegar, crie o doc e então chame abrirPage(ref))
                }
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _selectedTime == t
                    ? _CalColors.chipSelBg
                    : _CalColors.chipBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _selectedTime == t
                      ? Colors.transparent
                      : _CalColors.chipBorder,
                ),
              ),
              child: Text(
                _fmt(context, t),
                style: TextStyle(
                  color: _selectedTime == t
                      ? _CalColors.chipSelText
                      : _CalColors.chipText,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedDayOrdersCard() {
    if (_selectedDate == null) return const SizedBox.shrink();
    final items = _ordersForDay(_selectedDate!);
    if (items.isEmpty) return const SizedBox.shrink();

    final dateLabel = DateFormat('EEE, MMM d').format(_selectedDate!);

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
            'Pedidos em $dateLabel',
            style: const TextStyle(
              color: _CalColors.textPri,
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((o) {
            final dt = o.dia;
            final timeStr =
                (dt != null) ? DateFormat('HH:mm').format(dt) : 'Sem horário';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.event, size: 18, color: _CalColors.textSec),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pedido • $timeStr',
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
    // Altura “infinita”: sem height fixo e sem scroll interno.
    return Container(
      width: widget.width ?? double.infinity,
      // height: widget.height, // propositalmente não usado
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _CalColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: _CalColors.textPri),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // ajusta à altura do conteúdo
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
          ],
        ),
      ),
    );
  }
}
