part of 'meter_bloc.dart';

sealed class MeterState extends Equatable {
  const MeterState();

  @override
  List<Object> get props => [];
}

final class MeterInitial extends MeterState {}

class MeterLoading extends MeterState {}

// ignore: must_be_immutable
class MeterLoaded extends MeterState {
  List<Meter> meters;
  final int totalMeters;
  MeterLoaded({required this.meters}) : totalMeters = meters.length;

  @override
  List<Object> get props => [meters, totalMeters];
}

class MeterError extends MeterState {}
