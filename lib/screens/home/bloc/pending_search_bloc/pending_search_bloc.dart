import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:metric_repository/metric_repository.dart';

part 'pending_search_event.dart';
part 'pending_search_state.dart';

class PendingSearchBloc extends Bloc<PendingSearchEvent, PendingSearchState> {
  final DatabaseHelper _dbHelper;
  PendingSearchBloc(this._dbHelper) : super(PendingSearchInitial()) {
    on<SearchEvent>((event, emit) async {
      emit(SearchLoading());
      try {
        List<Metric> metrics = await _dbHelper.getPendingMeters();
        final query = event.query.toLowerCase();
        final filteredMetrics = metrics.where((metric) {
          return metric.number!.toLowerCase().contains(query) ||
              metric.name!.toLowerCase().contains(query) ||
              metric.address!.toLowerCase().contains(query);
        }).toList();
        emit(SearchLoaded(filteredMetrics));
      } catch (e) {
        log(e.toString());
        emit(SearchError());
      }
    });
  }
}
