part of 'prelevement_bloc.dart';

sealed class PrelevementState extends Equatable {
  const PrelevementState();

  @override
  List<Object> get props => [];
}

final class PrelevementInitial extends PrelevementState {}
final class PrelevementLoading extends PrelevementState {}
final class PrelevementSuccess extends PrelevementState {}
final class PrelevementFailure extends PrelevementState {
  final String error;
  const PrelevementFailure(this.error);
}


