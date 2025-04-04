import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:otaku_world/config/router/router_constants.dart';
import 'package:otaku_world/constants/filter_constants.dart';
import 'package:otaku_world/core/ui/filters/custom_dropdown.dart';
import 'package:otaku_world/graphql/__generated/graphql/schema.graphql.dart';
import 'package:otaku_world/graphql/__generated/graphql/user/user_stats.graphql.dart';
import 'package:otaku_world/theme/colors.dart';
import 'package:otaku_world/utils/formatting_utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../../generated/assets.dart';

class ReleaseYearDistributionChart extends StatefulWidget {
  const ReleaseYearDistributionChart({
    super.key,
    required this.releaseYears,
    required this.type,
  });

  final List<Fragment$UserStatistics$releaseYears?>? releaseYears;
  final Enum$MediaType type;

  @override
  State<ReleaseYearDistributionChart> createState() =>
      _ReleaseYearDistributionChartState();
}

class _ReleaseYearDistributionChartState
    extends State<ReleaseYearDistributionChart> {
  late String option;

  @override
  void initState() {
    option = widget.type == Enum$MediaType.ANIME
        ? FilterConstants.releaseYearOptionsAnime[0]
        : FilterConstants.releaseYearOptionsManga[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - 20;
    final width = widget.releaseYears!.length * 30;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Release Year Distribution',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontFamily: 'Roboto-Medium',
                    ),
              ),
              IconButton(
                onPressed: () {
                  context.push(
                    '${RouteConstants.releaseYearDistribution}?type=${widget.type == Enum$MediaType.ANIME ? 'anime' : 'manga'}',
                    extra: widget.releaseYears,
                  );
                },
                icon: SvgPicture.asset(
                  Assets.iconsArrowRight,
                ),
              ),
            ],
          ),
        ),
        CustomDropdown(
          dropdownItems: widget.type == Enum$MediaType.ANIME
              ? FilterConstants.releaseYearOptionsAnime
              : FilterConstants.releaseYearOptionsManga,
          initialValue: option,
          onChange: (value) {
            setState(() {
              option = value;
            });
          },
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            width: max(width.toDouble(), screenWidth),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: AppColors.chartGradient,
            ),
            child: SfCartesianChart(
              key: UniqueKey(),
              // margin: const EdgeInsets.all(15),
              plotAreaBorderColor: Colors.transparent,
              tooltipBehavior: TooltipBehavior(
                enable: true,
                header: 'Release Year',
              ),
              primaryXAxis: CategoryAxis(
                arrangeByIndex: true,
                majorGridLines: const MajorGridLines(width: 0),
                axisLabelFormatter: (axisLabelRenderArgs) => ChartAxisLabel(
                  axisLabelRenderArgs.text,
                  const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              primaryYAxis: const NumericAxis(isVisible: false),
              series: <CartesianSeries<Fragment$UserStatistics$releaseYears?,
                  int>>[
                SplineAreaSeries<Fragment$UserStatistics$releaseYears?, int>(
                  sortingOrder: SortingOrder.ascending,
                  dataSource: widget.releaseYears,
                  xValueMapper: (data, _) => data?.releaseYear,
                  yValueMapper: _mapYValue,
                  sortFieldValueMapper: (datum, index) => datum?.releaseYear,
                  borderColor: AppColors.sunsetOrange,
                  gradient: AppColors.primaryGradient,
                  enableTooltip: true,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    color: AppColors.white,
                    borderColor: AppColors.sunsetOrange,
                    borderWidth: 3,
                  ),
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    margin: EdgeInsets.all(0),
                    labelAlignment: ChartDataLabelAlignment.top,
                    textStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  num? _mapYValue(Fragment$UserStatistics$releaseYears? data, int index) {
    switch (option) {
      case 'Titles Watched' || 'Titles Read':
        return data?.count;
      case 'Hours Watched':
        return int.parse(
          FormattingUtils.minutesToHours(data?.minutesWatched ?? 0),
        );
      case 'Mean Score':
        return data?.meanScore;
      case 'Chapters Read':
        return data?.chaptersRead;
      default:
        return data?.count;
    }
  }
}
