part of 'pending_search_bloc.dart';

sealed class PendingSearchState extends Equatable {
  const PendingSearchState();

  @override
  List<Object> get props => [];
}

final class PendingSearchInitial extends PendingSearchState {}

class SearchLoading extends PendingSearchState {}

class SearchLoaded extends PendingSearchState {
  final List<Metric> metrics;
  const SearchLoaded(this.metrics);

  @override
  List<Object> get props => [metrics];
}

class SearchError extends PendingSearchState {}
