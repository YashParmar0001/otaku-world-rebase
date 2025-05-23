import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:otaku_world/bloc/studio_detail/studio_detail_bloc.dart';
import 'package:otaku_world/core/ui/media_section/media_grid_list.dart';
import 'package:otaku_world/features/media_detail/widgets/simple_loading.dart';
import 'package:otaku_world/features/studio_detail/widgets/studio_app_bar.dart';
import 'package:otaku_world/graphql/__generated/graphql/schema.graphql.dart';
import 'package:otaku_world/utils/navigation_helper.dart';

import '../../../bloc/graphql_client/graphql_client_cubit.dart';
import '../../../bloc/paginated_data/paginated_data_bloc.dart';
import '../../../bloc/studio_detail/studio_media/studio_media_bloc.dart';
import '../../../core/ui/media_section/scroll_to_top_button.dart';
import '../../../theme/colors.dart';

class StudioDetailScreen extends HookWidget {
  const StudioDetailScreen({
    super.key,
    required this.studioId,
  });

  final int studioId;
  static const Widget fifteenSpacing = SizedBox(
    height: 15,
  );

  static const Widget twentySpacing = SizedBox(
    height: 20,
  );

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();

    final bloc = context.read<StudioMediaBloc>();

    useEffect(() {
      scrollController.addListener(() {
        final maxScroll = scrollController.position.maxScrollExtent;
        final currentScroll = scrollController.position.pixels;

        if (currentScroll == maxScroll) {
          final hasNextPage = (bloc.state as PaginatedDataLoaded).hasNextPage;
          if (hasNextPage) {
            final client = (context.read<GraphqlClientCubit>().state
                    as GraphqlClientInitialized)
                .client;
            bloc.add(LoadData(client));
          }
        }
      });
      return null;
    }, const []);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        NavigationHelper.onPopInvoked(context);
      },
      child: Scaffold(
        floatingActionButton: ScrollToTopFAB(
          controller: scrollController,
          tag: 'studio_fab',
        ),
        body: BlocBuilder<StudioDetailBloc, StudioDetailState>(
          builder: (context, state) {
            if (state is StudioDetailInitial || state is StudioDetailLoading) {
              return const SimpleLoading();
            } else if (state is StudioDetailLoaded) {
              final studio = state.studio;
              return CustomScrollView(
                controller: scrollController,
                slivers: [
                  StudioAppBar(
                    studio: studio,
                    bloc: bloc,
                  ),
                  SliverToBoxAdapter(
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: const MediaGridList<StudioMediaBloc>(
                        crossAxisCount: 3,
                        mediaType: Enum$MediaType.ANIME,
                        isNeedToShowFormatAndYear: true,
                      ),
                    ),
                  ),
                ],
              );
            }
            return const Center(
              child: Text(
                'Unknown State',
                style: TextStyle(
                  color: AppColors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
