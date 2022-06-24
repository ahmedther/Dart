import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Providers with ChangeNotifier {
  bool _show_confrim_image = false;

  get show_confrim_image => _show_confrim_image;

  showConfirmImage(bool value) {
    _show_confrim_image = value;

    notifyListeners();
    return value;
  }

  var _docProfileObject = null;
  get docProfileObject => _docProfileObject;

  docProfileObjectNullifier() {
    _docProfileObject = null;
  }

  Future editDoctorHTTPRequest(docPhoneNum) async {
    // final url = Uri.parse(
    //     'https://gpprofiler-default-rtdb.asia-southeast1.firebasedatabase.app/doctors_profile.json');
    // try {
    //   final response = await http.get(url);
    //   print(json.decode(response.body));
    // } catch (e) {
    //   throw (e);
    // }
    try {
      await FirebaseFirestore.instance
          .collection('doctors_profile')
          .doc(docPhoneNum)
          .get()
          .then((value) {
        _docProfileObject = value.data();
        if (_docProfileObject == null) {
          return null;
        }
      });
    } catch (error) {
      return error;
    }

    notifyListeners();
  }
}
