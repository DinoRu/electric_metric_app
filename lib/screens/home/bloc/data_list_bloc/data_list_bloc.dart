import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:metric_repository/metric_repository.dart';

part 'data_list_event.dart';
part 'data_list_state.dart';

class DataListBloc extends Bloc<DataListEvent, DataListState> {
  final DatabaseHelper databaseHelper = DatabaseHelper();
  DataListBloc() : super(DataListInitial()) {
    on<DataListEvent>((event, emit) async {
      emit(DataListLoading());
      try {
        List<Map<String, dynamic>> data =
            await databaseHelper.getMetersByStatus('Проверяется');
        List<Metric> metrics = data
            .map((e) => Metric(
                  taskId: e["taskId"],
                  code: e["code"],
                  name: e["name"],
                  address: e["address"],
                  number: e["number"],
                  previousIndication: e["previousIndication"],
                  currentIndication: e["currentIndication"],
                  nearPhotoUrl: e["nearPhotoUrl"],
                  farPhotoUrl: e["farPhotoUrl"],
                  comment: e["comment"],
                  status: e["status"],
                ))
            .toList();
        emit(DataListLoaded(metrics));
      } catch (e) {
        emit(DataListError());
        throw Exception(e);
      }
    });
  }
}
