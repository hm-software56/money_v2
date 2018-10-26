/// Forward pattern hatch bar chart example
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

/// Forward hatch pattern horizontal bar chart example.
///
/// The second series of bars is rendered with a pattern by defining a
/// fillPatternFn mapping function.
class HorizontalPatternForwardHatchBarChartM extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  HorizontalPatternForwardHatchBarChartM(this.seriesList, {this.animate});

  factory HorizontalPatternForwardHatchBarChartM.withSampleData(final a,final b) {
    return new HorizontalPatternForwardHatchBarChartM(
      _createSampleData(a,b),
      // Disable animations for image tests.
      animate: false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      barGroupingType: charts.BarGroupingType.grouped,
      vertical: false,
    );
  }

  /// Create series list with multiple series
  static List<charts.Series<OrdinalSalesM, String>> _createSampleData(final a, final b) {

    return [
      new charts.Series<OrdinalSalesM, String>(
        id: 'Desktopm',
        domainFn: (OrdinalSalesM sales, _) => sales.year,
        measureFn: (OrdinalSalesM sales, _) => sales.sales,
         colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        data: a,
      ),
      new charts.Series<OrdinalSalesM, String>(
        id: 'Tabletm',
        domainFn: (OrdinalSalesM sales, _) => sales.year,
        measureFn: (OrdinalSalesM sales, _) => sales.sales,
        data: b,
         colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      ),
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSalesM {
  final String year;
  final int sales;

  OrdinalSalesM(this.year, this.sales);
}