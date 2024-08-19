import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:metric_repository/metric_repository.dart';
import 'package:user_repository/user_repository.dart';

part 'meter_event.dart';
part 'meter_state.dart';

class MeterBloc extends Bloc<MeterEvent, MeterState> {
  final MetricRepository metricRepository;
  List<Meter> meters = [];
  MeterBloc(this.metricRepository) : super(MeterInitial()) {
    on<GetMeterEvent>((event, emit) async {
      emit(MeterLoading());
      try {
        meters = await metricRepository.getMeterByUser(event.user);
        final updatedMeters = meters.map((meter) {
          return meter.copyWith(implementer: event.user.lastName);
        }).toList();
        emit(MeterLoaded(meters: updatedMeters));
      } catch (e) {
        log(e.toString());
        emit(MeterError());
      }
    });
  }

  List<Meter> getMeters() {
    return meters;
  }
}
