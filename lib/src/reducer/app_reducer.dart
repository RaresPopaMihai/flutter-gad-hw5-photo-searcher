import 'package:redux/redux.dart';

import '../actions/index.dart';
import '../models/index.dart';

AppState reducer(AppState state, dynamic action) {
  return _reducer(state, action);
}

Reducer<AppState> _reducer = combineReducers(<Reducer<AppState>>[
  TypedReducer<AppState, GetImagesSuccessful>(_getImagesStart).call,
  TypedReducer<AppState, GetImagesSuccessful>(_getImagesSuccessful).call,
  TypedReducer<AppState, GetImagesSuccessful>(_getImagesError).call
]);

AppState _getImagesSuccessful(AppState state, GetImagesSuccessful action) {
  return state.copyWith(
    images: <Picture>[...state.images, ...action.images],
    isLoading: false,
    hasMore: action.images.isNotEmpty,
    page: state.page + 1,
  );
}

AppState _getImagesStart(AppState state, GetImagesSuccessful action) {
  return state.copyWith(isLoading: true);
}

AppState _getImagesError(AppState state, GetImagesSuccessful action) {
  return state.copyWith(isLoading: false);
}
