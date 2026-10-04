import 'package:core_localization/core_localization.dart';
import 'package:flutter/material.dart';

import '../theme/foodie_color_tokens.dart';
import '../theme/foodie_spacing.dart';
import 'chart_data.dart';

/// The frame of every chart: title, optional subtitle, and a "Table" switch
/// that replaces the chart with its exact values (architecture document,
/// section 10.6). When [emptyMessage] is set it is shown instead of the
/// chart, so thin data is explained rather than drawn misleadingly.
class ChartCard extends StatefulWidget {
  const ChartCard({
    required this.title,
    required this.chart,
    required this.table,
    this.subtitle,
    this.notice,
    this.emptyMessage,
    this.headerControl,
    super.key,
  });

  final String title;
  final String? subtitle;

  /// A hint above the chart that does not replace it, such as "Only 3
  /// removals in this period; trends need more data".
  final String? notice;
  final String? emptyMessage;

  /// A control between the header and the chart, such as an
  /// "Eaten / Thrown away" switch.
  final Widget? headerControl;
  final Widget chart;
  final ChartTable table;

  @override
  State<ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<ChartCard> {
  bool _isShowingTable = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final commonLocalizations = context.commonLocalizations;
    final mutedStyle = theme.textTheme.bodySmall?.copyWith(color: context.freezerColors.textMuted);
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          FoodieSpacing.medium,
          FoodieSpacing.small,
          FoodieSpacing.medium,
          FoodieSpacing.medium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                if (widget.emptyMessage == null)
                  TextButton(
                    onPressed: () => setState(() => _isShowingTable = !_isShowingTable),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: FoodieSpacing.small),
                    ),
                    child: Text(
                      _isShowingTable
                          ? commonLocalizations.chartShowChart
                          : commonLocalizations.chartShowTable,
                    ),
                  ),
              ],
            ),
            if (widget.subtitle != null) Text(widget.subtitle!, style: mutedStyle),
            const SizedBox(height: FoodieSpacing.small),
            ?widget.headerControl,
            if (widget.notice != null && widget.emptyMessage == null)
              Padding(
                padding: const EdgeInsets.only(bottom: FoodieSpacing.small),
                child: Text(widget.notice!, style: mutedStyle),
              ),
            if (widget.emptyMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: FoodieSpacing.large,
                  horizontal: FoodieSpacing.extraSmall,
                ),
                child: Text(widget.emptyMessage!, style: mutedStyle, textAlign: TextAlign.center),
              )
            else if (_isShowingTable)
              ChartDataTable(table: widget.table)
            else
              widget.chart,
          ],
        ),
      ),
    );
  }
}

/// A compact table of a chart's values; scrolls sideways when it has many columns.
class ChartDataTable extends StatelessWidget {
  const ChartDataTable({required this.table, super.key});

  final ChartTable table;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.labelMedium?.copyWith(
      color: context.freezerColors.textMuted,
    );
    final cellStyle = theme.textTheme.bodySmall;
    Widget cell(String text, TextStyle? style, {required bool isFirstColumn}) => Padding(
      padding: const EdgeInsets.symmetric(
        vertical: FoodieSpacing.extraSmall,
        horizontal: FoodieSpacing.small,
      ),
      child: Text(text, style: style, textAlign: isFirstColumn ? TextAlign.start : TextAlign.end),
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder(horizontalInside: BorderSide(color: context.freezerColors.border)),
        children: [
          TableRow(
            children: [
              for (final (index, header) in table.columnHeaders.indexed)
                cell(header, headerStyle, isFirstColumn: index == 0),
            ],
          ),
          for (final row in table.rows)
            TableRow(
              children: [
                for (final (index, value) in row.indexed)
                  cell(value, cellStyle, isFirstColumn: index == 0),
              ],
            ),
        ],
      ),
    );
  }
}
