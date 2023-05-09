

import 'package:redux/redux.dart';

import '../actions/index.dart';
import '../models/index.dart';

AppState reducer(AppState state, dynamic action) {

  return _reducer(state, action);
}

Reducer<AppState> _reducer = combineReducers(<Reducer<AppState>>[
  TypedReducer<AppState, GetImagesSuccessful> (_getImagesSuccessful).call,
]);

AppState _getImagesSuccessful(AppState state, GetImagesSuccessful action) {
  return state.copyWith(images: [...state.images, ...action.images]);
}
