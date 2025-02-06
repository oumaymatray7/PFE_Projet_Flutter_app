// Enum for Event Types
enum EventType { Personal, Holiday, Family, ETC, Business }

// Definition of the Eventt class
class Eventt {
  final String title;
  final String description;
  final DateTime date;
  final EventType type;

  Eventt({
    required this.title,
    required this.description,
    required this.date,
    required this.type,
  });
}

// Class to manage a list of events
class EventList {
  List<Eventt> events = [];

  void addEvent(Eventt event) {
    events.add(event);
  }

  List<Eventt> getEvents() {
    return events;
  }
}

// Example of adding an event to the event list
EventList eventList = EventList();

void addSampleEvents() {
  eventList.addEvent(Eventt(
    title: "Project Meeting",
    description: "Meeting to discuss project milestones",
    date: DateTime.now(),
    type: EventType.Business,
  ));

  eventList.addEvent(Eventt(
    title: "Family Reunion",
    description: "Annual family reunion at the park",
    date: DateTime.now().add(Duration(days: 5)),
    type: EventType.Family,
  ));

  // You can continue adding more events as needed
}
