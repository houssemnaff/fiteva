import 'package:fiteva/screens/community/model/event_model.dart';
import 'package:flutter/material.dart';

import '../shared/community_shared_widgets.dart';

class ParticipantsSheet extends StatelessWidget {
  final EventModel event;
  final ColorScheme colorScheme;

  const ParticipantsSheet({super.key, required this.event, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetHandle(),
          const SizedBox(height: 20),
          Text(
            'Participants (${event.joinedCount}/${event.maxSpots})',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          ...event.participantAvatars.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(e.value),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Participant ${e.key + 1}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}