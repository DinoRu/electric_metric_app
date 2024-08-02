part of 'pending_bloc.dart';

sealed class PendingState extends Equatable {
  const PendingState();

  @override
  List<Object> get props => [];
}

final class PendingInitial extends PendingState {}

class PendingLoading extends PendingState {}

class PendingLoaded extends PendingState {
  final List<PendingMeter> pendingMeters;

  const PendingLoaded({required this.pendingMeters});

  @override
  List<Object> get props => [pendingMeters];
}

class PendingError extends PendingState {
  final String error;
  const PendingError({required this.error});

  @override
  List<Object> get props => [error];
}

class PendingEmpty extends PendingState {}
