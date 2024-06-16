part of 'search_bloc.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

final class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

// ignore: must_be_immutable
class SearchLoaded extends SearchState {
  List<Metric> metrics;
  SearchLoaded(this.metrics);

  @override
  List<Object> get props => [metrics];
}

class SearchError extends SearchState {}
