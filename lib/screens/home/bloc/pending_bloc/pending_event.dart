part of 'pending_bloc.dart';

sealed class PendingEvent extends Equatable {
  const PendingEvent();

  @override
  List<Object> get props => [];
}

class FetchPendingMeterEvent extends PendingEvent {}
