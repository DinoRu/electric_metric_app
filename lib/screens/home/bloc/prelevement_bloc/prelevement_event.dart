part of 'prelevement_bloc.dart';

sealed class PrelevementEvent extends Equatable {
  const PrelevementEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}


class SubmitEvent extends PrelevementEvent {
  final String meterId;
  final String meterName;
  final double previousIndication;
  final double currentIndication;
  final String? comment;
  final XFile meterImage;
  final XFile metricImage;

  const SubmitEvent(
      {
        required this.meterId,
        required this.meterName,
        required this.previousIndication,
        required this.currentIndication,
        this.comment,
        required this.meterImage,
        required this.metricImage

        });

  @override
  List<Object?> get props => [meterId];
}