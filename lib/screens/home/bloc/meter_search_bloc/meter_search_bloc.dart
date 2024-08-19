import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:metric_repository/metric_repository.dart';
import 'package:user_repository/user_repository.dart';

part 'meter_search_event.dart';
part 'meter_search_state.dart';

class MeterSearchBloc extends Bloc<MeterSearchEvent, MeterSearchState> {
  final MetricRepository _metricRepository;
  MeterSearchBloc(this._metricRepository) : super(MeterSearchInitial()) {
    on<SearchEvent>((event, emit) async {
      emit(SearchLoading());
      try {
        List<Meter> meters = await _metricRepository.getMeterByUser(event.user);
        final filteredMeters = meters.where((meter) {
          return meter.number!
                  .toLowerCase()
                  .contains(event.query.toLowerCase()) ||
              meter.name!.toLowerCase().contains(event.query.toLowerCase()) ||
              meter.address!.toLowerCase().contains(event.query.toLowerCase());
        }).toList();
        emit(SearchLoaded(filteredMeters));
      } catch (e) {
        log(e.toString());
        emit(SearchError());
      }
    });
  }
}
