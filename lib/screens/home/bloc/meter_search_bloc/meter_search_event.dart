part of 'meter_search_bloc.dart';

sealed class MeterSearchEvent extends Equatable {
  const MeterSearchEvent();

  @override
  List<Object> get props => [];
}

class SearchEvent extends MeterSearchEvent {
  final String query;
  final User user;
  const SearchEvent({required this.user, required this.query});

  @override
  List<Object> get props => [user];
}
