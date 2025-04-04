import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otaku_world/bloc/media_detail/staff/staff_bloc.dart';
import 'package:otaku_world/features/media_detail/tabs/staff/staff_card.dart';
import 'package:otaku_world/graphql/__generated/graphql/details/staff.graphql.dart';

import '../../../../bloc/graphql_client/graphql_client_cubit.dart';
import '../../../../bloc/paginated_data/paginated_data_bloc.dart';
import '../../widgets/simple_loading.dart';

class Staff extends StatelessWidget {
  const Staff({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StaffBloc, PaginatedDataState>(
      builder: (context, state) {
        if (state is PaginatedDataInitial) {
          final client = (context.read<GraphqlClientCubit>().state
                  as GraphqlClientInitialized)
              .client;
          context.read<StaffBloc>().add(LoadData(client));
          return const SimpleLoading();
        } else if (state is PaginatedDataLoading) {
          return const SimpleLoading();
        } else if (state is PaginatedDataLoaded) {
          List<Query$MediaStaff$Media$staff$edges?> staffs =
              state.list as List<Query$MediaStaff$Media$staff$edges?>;
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                final staffBloc = context.read<StaffBloc>();
                final hasNextPage =
                    (staffBloc.state as PaginatedDataLoaded).hasNextPage;
                if (hasNextPage) {
                  final client = (context.read<GraphqlClientCubit>().state
                          as GraphqlClientInitialized)
                      .client;
                  staffBloc.add(LoadData(client));
                }
              }
              return false;
            },
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(10),
                  sliver: SliverList.separated(
                    itemCount: staffs.length,
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 10,
                    ),
                    itemBuilder: (context, index) {
                      return StaffCard(staff: staffs[index]!);
                    },
                  ),
                ),
                if (state.hasNextPage)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }
        return const Text(
          'Unknown State',
          style: TextStyle(color: Colors.white),
        );
      },
    );
  }
}
