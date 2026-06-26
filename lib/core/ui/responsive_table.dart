import 'package:flutter/material.dart';
import 'responsive.dart';

class ResponsiveTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final ScrollController? controller;

  final double? minWidth;
  final bool showCard;

  const ResponsiveTable({
    super.key,
    required this.columns,
    required this.rows,
    this.controller,
    this.minWidth,
    this.showCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    // ───────────────── PARAMETRI DINAMICI ─────────────────

    final columnSpacing = _columnSpacing(responsive);
    final horizontalMargin = _horizontalMargin(responsive);
    final rowHeight = _rowHeight(responsive);
    final headingHeight = _headingHeight(responsive);
    final effectiveMinWidth = minWidth ?? _defaultMinWidth(responsive);

    Widget table = Scrollbar(
      controller: controller,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: effectiveMinWidth),
          child: DataTable(
            columnSpacing: columnSpacing,
            horizontalMargin: horizontalMargin,
            dataRowMinHeight: rowHeight,
            dataRowMaxHeight: rowHeight,
            headingRowHeight: headingHeight,
            columns: columns,
            rows: rows,
          ),
        ),
      ),
    );

    if (!showCard) return table;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: table,
    );
  }

  // ───────────────── CONFIG RESPONSIVE ─────────────────

  double _columnSpacing(Responsive r) {
    switch (r.screenSize) {
      case ScreenSize.mobile:
        return 16;
      case ScreenSize.tablet:
        return 24;
      case ScreenSize.desktop:
        return 48;
    }
  }

  double _horizontalMargin(Responsive r) {
    switch (r.screenSize) {
      case ScreenSize.mobile:
        return 12;
      case ScreenSize.tablet:
        return 16;
      case ScreenSize.desktop:
        return 32;
    }
  }

  double _rowHeight(Responsive r) {
    switch (r.screenSize) {
      case ScreenSize.mobile:
        return 48;
      case ScreenSize.tablet:
        return 56;
      case ScreenSize.desktop:
        return 64;
    }
  }

  double _headingHeight(Responsive r) {
    switch (r.screenSize) {
      case ScreenSize.mobile:
        return 48;
      case ScreenSize.tablet:
        return 56;
      case ScreenSize.desktop:
        return 60;
    }
  }

  double _defaultMinWidth(Responsive r) {
    switch (r.screenSize) {
      case ScreenSize.mobile:
        return 500;
      case ScreenSize.tablet:
        return 700;
      case ScreenSize.desktop:
        return 900;
    }
  }
}