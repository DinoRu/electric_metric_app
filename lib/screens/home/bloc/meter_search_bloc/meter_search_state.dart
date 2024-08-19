part of 'meter_search_bloc.dart';

sealed class MeterSearchState extends Equatable {
  const MeterSearchState();

  @override
  List<Object> get props => [];
}

final class MeterSearchInitial extends MeterSearchState {}

class SearchLoading extends MeterSearchState {}

class SearchLoaded extends MeterSearchState {
  final List<Meter> meters;
  const SearchLoaded(this.meters);

  @override
  List<Object> get props => [meters];
}

class SearchError extends MeterSearchState {}
