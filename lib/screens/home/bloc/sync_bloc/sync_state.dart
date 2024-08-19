part of 'sync_bloc.dart';

sealed class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object> get props => [];
}

final class SyncInitial extends SyncState {}

class SyncLoading extends SyncState {}

class SyncSuccess extends SyncState {}

class SyncError extends SyncState {
  final String error;
  const SyncError(this.error);

  @override
  List<Object> get props => [error];
}
