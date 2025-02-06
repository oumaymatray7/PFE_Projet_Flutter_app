import 'package:flutter/material.dart';
import 'package:mobile_app/calendar/editEvent.dart';

class EventActionsDialog extends StatelessWidget {
  final String eventId;
  final Map<String, dynamic> event;
  final Function onDelete;

  EventActionsDialog({
    required this.eventId,
    required this.event,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Event Actions'),
      content: Text('Choose an action for this event.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  EditEventScreen(eventId: eventId, event: event),
            ));
          },
          child: Text('Edit Event'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDelete(eventId);
          },
          child: Text('Delete Event'),
        ),
      ],
    );
  }
}
