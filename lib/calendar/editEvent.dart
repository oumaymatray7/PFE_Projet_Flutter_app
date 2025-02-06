import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/services/calendarService/service_calendar.dart';

class EditEventScreen extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> event;

  const EditEventScreen({
    Key? key,
    required this.eventId,
    required this.event,
  }) : super(key: key);

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final CalendarService _calendarService = CalendarService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 1));
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd hh:mm a');

  String? selectedGuests;
  List<String> selectedGuestsList = [];
  String? selectedCalendar;

  final List<String> guestOptions = [
    'guest 1',
    'guest 2',
    'guest 3',
    'guest 4',
    'guest 5'
  ];
  final List<String> calendarOptions = [
    "Personal",
    "Holiday",
    "Family",
    "Business",
  ];

  @override
  void initState() {
    super.initState();

    _titleController.text = widget.event['title'];

    // Debugging prints to check the date strings
    print('Start Date: ${widget.event['start_date']}');
    print('End Date: ${widget.event['end_date']}');

    // Parse the start date
    _startDate =
        DateFormat('yyyy-MM-dd hh:mm a').parse(widget.event['start_date']);
    _startDateController.text = dateFormat.format(_startDate);

    // Check and parse the end date if it exists and is not empty
    if (widget.event['end_date'] != null &&
        widget.event['end_date'].isNotEmpty) {
      _endDate =
          DateFormat('yyyy-MM-dd hh:mm a').parse(widget.event['end_date']);
      _endDateController.text = dateFormat.format(_endDate);
    }
  }

  void _updateEvent() async {
    if (_formKey.currentState!.validate()) {
      User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      Map<String, dynamic> eventData = {
        'title': _titleController.text,
        'calendar': selectedCalendar ?? 'ETC',
        'start_date': _startDateController.text,
        'end_date': _endDateController.text,
        'event_url': _urlController.text,
        'guests': selectedGuestsList,
        'description': _descriptionController.text,
        'created_by': currentUser.uid,
      };

      try {
        await _calendarService.updateEvent(widget.eventId, eventData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event updated successfully')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          reverse: true,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(40, 36, 61, 1),
              ),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(40, 36, 61, 1),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      TextFormField(
                        controller: _titleController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an event title';
                          }
                          return null;
                        },
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Title*',
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(145, 85, 253, 1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(145, 85, 253, 1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(145, 85, 253, 1),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedCalendar,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Calendar',
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(145, 85, 253, 1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(145, 85, 253, 1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(145, 85, 253, 1),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedCalendar = value!;
                          });
                        },
                        dropdownColor: Color.fromRGBO(40, 36, 61, 1),
                        items: calendarOptions.map((option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _startDateController,
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a start date';
                          }
                          return null;
                        },
                        onTap: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            final selectedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (selectedTime != null) {
                              setState(() {
                                _startDate = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  selectedTime.hour,
                                  selectedTime.minute,
                                );
                                _startDateController.text =
                                    dateFormat.format(_startDate);
                              });
                            }
                          }
                        },
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Start Date*',
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(145, 85, 253, 1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(145, 85, 253, 1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(145, 85, 253, 1),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _endDateController,
                        readOnly: true,
                        onTap: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            final selectedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (selectedTime != null) {
                              setState(() {
                                _endDate = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  selectedTime.hour,
                                  selectedTime.minute,
                                );
                                _endDateController.text =
                                    dateFormat.format(_endDate);
                              });
                            }
                          }
                        },
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(145, 85, 253, 1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(145, 85, 253, 1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(145, 85, 253, 1),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _urlController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Event URL',
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(145, 85, 253, 1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(145, 85, 253, 1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(145, 85, 253, 1),
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedGuests,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Guests',
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(145, 85, 253, 1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(145, 85, 253, 1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(145, 85, 253, 1),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedGuests = value!;
                          });
                        },
                        dropdownColor: Color.fromRGBO(40, 36, 61, 1),
                        items: guestOptions.map((option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(145, 85, 253, 1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(145, 85, 253, 1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(145, 85, 253, 1),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _updateEvent,
                            child: Text(
                              'Update Event',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                Color.fromRGBO(145, 85, 253, 1),
                              ),
                              foregroundColor: MaterialStateProperty.all(
                                Colors.white,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                Color.fromRGBO(40, 36, 61, 1),
                              ),
                              foregroundColor: MaterialStateProperty.all(
                                Colors.white,
                              ),
                              side: MaterialStateProperty.all(
                                BorderSide(
                                  color: Color.fromRGBO(145, 85, 253, 1),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
