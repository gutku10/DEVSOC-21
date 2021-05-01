import 'dart:async';

import 'package:AppU/widgets/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = "/dashboard";

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = false;
  Event event;
  Stream<Event> _stream;

  StreamSubscription<Event> _disposableStream;

  var _pastTrips = [];
  var _pastTripsMList = [];
  var _onGoingLocations = [];
  String _departureLocation;
  String _arrivedLocation = '';

  @override
  void initState() {
    _syncPastTrips();
    super.initState();
  }

  Future<void> _syncPastTrips() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      var _firebaseParentRef =
          FirebaseDatabase().reference().child('Parents/${user.uid}');
      final parentSnapshot = await _firebaseParentRef.once();

      if (parentSnapshot.value['Child Trips'] != null) {
        setState(() {
          _pastTripsMList = parentSnapshot.value['Child Trips'];
          _pastTripsMList = [..._pastTripsMList];
          _pastTripsMList.removeWhere((element) => element == null);
          _pastTrips = _pastTripsMList.reversed.toList();
        });
      }

      print('NOT UPDATING...');
      print(parentSnapshot.value['QR Code']);
      print(parentSnapshot.value['Trip']);

      if (parentSnapshot.value['QR Code'] == '' &&
          parentSnapshot.value['Trip'] == 'false') {
        print('Inside if');
        setState(() {
          _isLoading = false;
        });
        return;
      }
      var now = new DateTime.now();
      var formatter = new DateFormat('dd-MM-yyyy');
      String formattedDate = formatter.format(now);
      print('UPDATING...');
      final tripNumber = parentSnapshot.value['QR Code'];
      _stream = FirebaseDatabase.instance
          .reference()
          .child('QR Codes/$tripNumber/Location')
          .onValue;

      DatabaseReference _firebaseLocationRef =
          FirebaseDatabase().reference().child('QR Codes/$tripNumber');

      _disposableStream = _stream.listen((event) async {
        if (event.snapshot.value == null) {
          return;
        }
        _onGoingLocations = [...event.snapshot.value];
        _onGoingLocations.removeWhere((element) => element == null);
        if (_onGoingLocations.length > 0) {
          _departureLocation = _onGoingLocations[0];
          if (_onGoingLocations.length > 1) {
            _departureLocation = _onGoingLocations[1];
          }

          print(_onGoingLocations);
          int arrivedIndex = _onGoingLocations.indexOf('Arrived');
          print(arrivedIndex);
          if (arrivedIndex > -1) {
            _arrivedLocation = _onGoingLocations[arrivedIndex - 1];

            if (_pastTrips.length > _pastTripsMList.length) {
              _pastTrips[0] = {
                'Departure': _departureLocation,
                'Date': formattedDate,
                'Arrival': _arrivedLocation,
                'Device Id': tripNumber,
              };
            } else {
              _pastTrips.insert(0, {
                'Departure': _departureLocation,
                'Date': formattedDate,
                'Arrival': _arrivedLocation,
                'Device Id': tripNumber,
              });
            }

            _pastTripsMList.add({
              'Departure': _departureLocation,
              'Date': formattedDate,
              'Arrival': _arrivedLocation,
              'Device Id': tripNumber,
            });

            await _firebaseParentRef.update({
              'Child Trips': _pastTripsMList,
              'QR Code': '',
              'Trip': 'false',
            });

            await _firebaseLocationRef.update({
              'Location': ['Departed'],
            });

            setState(() {
              _isLoading = false;
            });
          } else {
            print('INSERING');

            if (!(_pastTrips.length > _pastTripsMList.length)) {
              _pastTrips.insert(0, {
                'Departure': _departureLocation,
                'Date': formattedDate,
                'Arrival': _arrivedLocation,
                'Device Id': tripNumber,
              });
            }

            setState(() {
              _isLoading = false;
            });
          }
          setState(() {
            _isLoading = false;
          });
        }
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print(error);
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    }
  }

  @override
  void dispose() {
    if (_disposableStream != null) {
      _disposableStream.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Building...');
    print(_pastTrips);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomAppBar(firstLine: 'Your past', secondLine: 'trips'),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _pastTrips.isEmpty
                  ? Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline),
                          Text(' Opps..No past trip!'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _pastTrips.length,
                      itemBuilder: (context, index) => Card(
                        elevation: 3,
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          title: Row(
                            children: [
                              SizedBox(
                                  width: 80,
                                  child: Text(_pastTrips[index]['Departure'])),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                child: Icon(
                                  Icons.flight_takeoff,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              Text(_pastTrips[index]['Arrival']),
                            ],
                          ),
                          subtitle: Text(_pastTrips[index]['Date']),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}
