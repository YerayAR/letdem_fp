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
  });

  final ReservedSpacePayload payload;
  final String spaceId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Track Location")),
      body: BlocProvider(
        create: (context) => TrackLocationCubit(OwnerTrackLocationSocket()),
        child: TrackLocationContent(payload: payload, spaceId: spaceId),
      ),
    );
  }
}
