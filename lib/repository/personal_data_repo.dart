import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hajjhealth/features/Autentication/model/personal_data.dart';

class PersonalDataRepository extends GetxController {
  static PersonalDataRepository get instance => Get.find();
  final _db = FirebaseFirestore.instance;
  createPersonalData(PersonalDataModel personal_data) async {
    await _db
        .collection("HajjHealth")
        .add(
          personal_data
              .toJson()
              .whenComplete(
                () => {
                  Get.snackbar(
                    "Success",
                    "Personal data added successfully",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  ),
                },
              )
              .catchError(
                (error) => {
                  Get.snackbar(
                    "Error",
                    "Failed to add personal data",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  ),
                },
              ),
        );
  }
}
