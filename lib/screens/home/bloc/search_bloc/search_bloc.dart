import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:metric_repository/metric_repository.dart';
import 'package:user_repository/user_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  MetricRepository metricRepository;
  SearchBloc(this.metricRepository) : super(SearchInitial()) {
    on<Search>((event, emit) async {
      emit(SearchLoading());
      try {
        List<Metric> metrics = await metricRepository.searchMetrics(event.user);
        final filteredMetrics = metrics.where((metric) {
          return metric.number!
                  .toLowerCase()
                  .contains(event.query.toLowerCase()) ||
              metric.name!.toLowerCase().contains(event.query.toLowerCase()) ||
              metric.address!.toLowerCase().contains(event.query.toLowerCase());
        }).toList();
        emit(SearchLoaded(filteredMetrics));
      } catch (e) {
        emit(SearchError());
      }
    });
  }
}
