part of 'meter_bloc.dart';

sealed class MeterEvent extends Equatable {
  const MeterEvent();

  @override
  List<Object> get props => [];
}

class GetMeterEvent extends MeterEvent {
  final User user;
  const GetMeterEvent({required this.user});

  @override
  List<Object> get props => [user];
}
