part of 'media_detail_bloc.dart';

abstract class MediaDetailEvent extends Equatable {
  const MediaDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadMediaDetail extends MediaDetailEvent {
  final int id;
  final GraphQLClient client;

  const LoadMediaDetail({required this.id, required this.client});
}

class ResetMediaData extends MediaDetailEvent {}

class UpdateDetailListEntry extends MediaDetailEvent {
  const UpdateDetailListEntry({required this.entry});

  final Fragment$MediaListEntry entry;
}

class RemoveDetailListEntry extends MediaDetailEvent {}
