import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/track_location/cubit/track_location_cubit.dart';
import 'package:letdem/features/track_location/widgets/track_location_content.dart';

class TrackLocationView extends StatelessWidget {
  const TrackLocationView({
    super.key,
    required this.payload,
    required this.spaceId,
    this.useTestServer = true,
  });

  final ReservedSpacePayload payload;
  final String spaceId;

  /// If true, connects to localhost test server instead of production
  /// Set to true when testing with the Python mock server
  final bool useTestServer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create:
            (context) => TrackLocationCubit(
              OwnerTrackLocationSocket(useTestServer: useTestServer),
            ),
        child: TrackLocationContent(payload: payload, spaceId: spaceId),
      ),
    );
  }
}
