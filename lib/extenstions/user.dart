import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/features/users/repository/user.repository.dart';
import 'package:letdem/features/users/user_bloc.dart';

extension UserBlocExtension on BuildContext {
  UserBloc get userBloc => BlocProvider.of<UserBloc>(this);

  LetDemUser? get userProfile {
    final state = userBloc.state;
    if (state is UserLoaded) {
      return state.user;
    }
    return null;
  }

// List<City>? get userCities {
//   final state = userBloc.state;
//   if (state is PlestuProfileLoadedState) {
//     return state.userCities;
//   }
//   return null;
// }
//
// List<Interest>? get userInterests {
//   final state = userBloc.state;
//   if (state is PlestuProfileLoadedState) {
//     return state.userInterests;
//   }
//   return null;
// }
}
