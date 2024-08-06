part of 'data_list_bloc.dart';

sealed class DataListEvent extends Equatable {
  const DataListEvent();

  @override
  List<Object> get props => [];
}

class GetPendingMetricEvent extends DataListEvent {}
