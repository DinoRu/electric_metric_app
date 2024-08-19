part of 'pending_search_bloc.dart';

sealed class PendingSearchEvent extends Equatable {
  const PendingSearchEvent();

  @override
  List<Object> get props => [];
}

class SearchEvent extends PendingSearchEvent {
  final String query;
  const SearchEvent(this.query);

  @override
  List<Object> get props => [query];
}
