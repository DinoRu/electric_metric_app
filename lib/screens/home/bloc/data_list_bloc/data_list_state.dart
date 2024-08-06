part of 'data_list_bloc.dart';

sealed class DataListState extends Equatable {
  const DataListState();

  @override
  List<Object> get props => [];
}

final class DataListInitial extends DataListState {}

class DataListLoading extends DataListState {}

class DataListLoaded extends DataListState {
  final List<Metric> metrics;
  final int total;
  const DataListLoaded(this.metrics) : total = metrics.length;
}

class DataListError extends DataListState {}
