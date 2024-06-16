part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class Search extends SearchEvent {
  final String query;
  final User user;
  const Search({required this.user, required this.query});

  @override
  List<Object> get props => [user];
}
