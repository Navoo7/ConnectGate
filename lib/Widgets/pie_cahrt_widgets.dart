import 'package:connectgate/Widgets/Indicator_widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PieChartWidget extends StatefulWidget {
  final Map<String, double> optionPercentages;

  const PieChartWidget({Key? key, required this.optionPercentages})
      : super(key: key);

  @override
  _PieChartWidgetState createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.black.withOpacity(0.3),
      Colors.black.withOpacity(0.4),
      Colors.black.withOpacity(0.6),
      Colors.black.withOpacity(0.7),
      Colors.black.withOpacity(0.9),
    ];

    return AspectRatio(
      aspectRatio: 3.4,
      child: Row(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius:
                      28, // Increase this value to make the hole bigger
                  sections: _showingSections(colors),
                ),

                // PieChartData(
                //   // centerSpaceColor: colors[touchedIndex % colors.length],
                //   pieTouchData: PieTouchData(
                //     touchCallback: (FlTouchEvent event, pieTouchResponse) {
                //       setState(() {
                //         if (!event.isInterestedForInteractions ||
                //             pieTouchResponse == null ||
                //             pieTouchResponse.touchedSection == null) {
                //           touchedIndex = -1;
                //           return;
                //         }
                //         touchedIndex = pieTouchResponse
                //             .touchedSection!.touchedSectionIndex;
                //       });
                //     },
                //   ),
                //   borderData: FlBorderData(show: false),
                //   sectionsSpace: 0,
                //   centerSpaceRadius: 20,
                //   sections: _showingSections(colors),
                // ),
              ),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          _buildIndicators(colors).paddingOnly(right: 35),
        ],
      ),
    );
  }

  Widget _buildIndicators(List<Color> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.optionPercentages.keys.map((option) {
        final index = widget.optionPercentages.keys.toList().indexOf(option);
        return Indicator(
          color: colors[index % colors.length],
          text: option,
          isSquare: true,
        );
      }).toList(),
    );
  }

  List<PieChartSectionData> _showingSections(List<Color> colors) {
    return widget.optionPercentages.entries.map((entry) {
      final index = widget.optionPercentages.keys.toList().indexOf(entry.key);
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 7.5 : 9.5;
      final radius = isTouched ? 45.0 : 38.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value,
        // title: '${entry.key}\n${entry.value.toStringAsFixed(1)}%',
        title:
            isTouched ? '${entry.key}' : '${entry.value.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: isTouched ? FontWeight.w500 : FontWeight.w400,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    }).toList();
  }
}
