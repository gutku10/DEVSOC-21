import 'package:AppU/widgets/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class OngoingTripScreen extends StatefulWidget {
  static const routeName = '/ongoin-trip-screen';

  @override
  _OngoingTripScreenState createState() => _OngoingTripScreenState();
}

class _OngoingTripScreenState extends State<OngoingTripScreen> {
  Stream<Event> _stream;

  Future<DataSnapshot> _getTripNumber() {
    final user = FirebaseAuth.instance.currentUser;
    var _firebaseRef =
        FirebaseDatabase().reference().child('Parents/${user.uid}');
    return _firebaseRef.once();
  }

  Stream<Event> _getStream(String tripNumber) {
    _stream = FirebaseDatabase.instance
        .reference()
        .child('QR Codes/$tripNumber/Location')
        .onValue;
    return _stream;
  }

  Stream<Event> _getStreamEmergency(String tripNumber) {
    _stream = FirebaseDatabase.instance
        .reference()
        .child('QR Codes/$tripNumber/Emergency')
        .onValue;
    return _stream;
  }

  @override
  void dispose() {
    _stream = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getTripNumber(),
        builder: (context, tripNumberSnapShot) {
          if (tripNumberSnapShot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(firstLine: 'Your ongoing', secondLine: 'trip'),
              tripNumberSnapShot.data.value['QR Code'] == ''
                  ? Expanded(
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline),
                            Text(' Opps..No ongoing Trip!'),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: StreamBuilder(
                          stream: _getStream(
                              tripNumberSnapShot.data.value['QR Code']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.data.snapshot.value == null) {
                              return Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline),
                                    Text(' Opps..No ongoing trip!'),
                                  ],
                                ),
                              );
                            }

                            // Emergency code here

                            List tripLocations = [];
                            tripLocations = [...snapshot.data.snapshot.value];
                            tripLocations
                                .removeWhere((element) => element == null);

                            return ListView.builder(
                                itemCount: tripLocations.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == tripLocations.length)
                                    return StreamBuilder(
                                      stream: _getStreamEmergency(
                                          tripNumberSnapShot
                                              .data.value['QR Code']),
                                      builder: (context, snapshot) {
                                        //Connection not made yet
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        if (snapshot.data.snapshot.value ==
                                            true) {
                                          return Center(
                                            child: TextButton(
                                                onPressed: () =>
                                                    launch("tel://8544985144"),
                                                child: Text("Emergency Call me", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)),),
                                          );
                                        } else {
                                          return Container();
                                        }
                                      },
                                    );
                                  else
                                    return Card(
                                      elevation: 3,
                                      child: ListTile(
                                        title: Text(tripLocations[index]),
                                        trailing: Icon(
                                          tripLocations[index] == 'Arrived'
                                              ? Icons.done
                                              : null,
                                          color: Colors.green,
                                        ),
                                      ),
                                    );
                                });
                          }),
                    ),
            ],
          );
        });
  }
}