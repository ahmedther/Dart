import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:form_field_validator/form_field_validator.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

import 'dart:io';
import 'dart:convert';
import '../customicons/custom_icons.dart';
import '../providers/providers.dart';
import 'package:provider/provider.dart';

class AddGPScreen extends StatefulWidget {
  const AddGPScreen({Key? key}) : super(key: key);
  static const routeName = '/add_gp_page';
  static const String heroTag = "gp_screen";

  @override
  State<AddGPScreen> createState() => _AddGPScreenState();
}

class _AddGPScreenState extends State<AddGPScreen> {
  File? picPhoto;
  UploadTask? uploadTask;
  String? profilePhotoUrl;
  bool isLoading = false;
  bool isEditScreen = false;
  bool isPhotoPicked = false;

  var defaultState;
  var defaultCategory;
  var defaultGender;
  var defaultSpeciality;
  var docPhoneNum;

  var _isInit = true;

// This Function checks and restrict users to repeat same phone numbers
  mobileNumberOnSubmit() {
    if (mobile_number.text.length == 10) {
      restrictRepeatPhoneNumber(mobile_number.text);
      FocusScope.of(context).requestFocus(nodeFirstName);
    }
  }

  Future restrictRepeatPhoneNumber(mobNumber) async {
    try {
      await FirebaseFirestore.instance
          .collection('doctors_profile')
          .doc(mobNumber)
          .get()
          .then((value) {
        docPhoneNum = value.data();

        if (docPhoneNum != null) {
          loadingFalse();
          FocusScope.of(context).requestFocus(nodeMobileNumber);
          return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Row(
                children: const [
                  Icon(CustomIcon1.attention, color: Colors.amber),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Number Already Exists"),
                ],
              ),
              content: Text(
                  "This Mobile Number is Already Registered with Dr.${docPhoneNum["first_name"]} ${docPhoneNum["last_name"]}. \n\nPlease Enter A Different Mobile Number"),
              actions: <Widget>[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.amber, onPrimary: Colors.white),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  icon: Icon(Icons.done),
                  label: Text('Okay'),
                )
              ],
            ),
          );
          ;
        }
      });
    } catch (error) {
      return error;
    }
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      var docProfileObjectEdit = context.read<Providers>().docProfileObject;
      context.read<Providers>().docProfileObjectNullifier();
      if (docProfileObjectEdit == null) {
        return;
      }
      if (docProfileObjectEdit != null) {
        mobile_number.text = docProfileObjectEdit["mobile_number"];
        first_name.text = docProfileObjectEdit["first_name"];
        last_name.text = docProfileObjectEdit["last_name"];
        address_building_street.text = docProfileObjectEdit["address_line1"];
        address_city.text = docProfileObjectEdit["city"];
        address_state.text = docProfileObjectEdit["state"];
        if (address_state.text != "") {
          defaultState = address_state.text;
        }
        address_pincode.text = docProfileObjectEdit["pincode"];
        profile_email.text = docProfileObjectEdit["email"];
        profile_category.text = docProfileObjectEdit["category"];
        if (profile_category.text != "") {
          defaultCategory = profile_category.text;
        }
        profile_gender.text = docProfileObjectEdit["gender"];
        if (profile_gender.text != "") {
          defaultGender = profile_gender.text;
        }
        profile_speciality.text = docProfileObjectEdit["speciality"];
        if (profile_speciality.text != "") {
          defaultSpeciality = profile_speciality.text;
        }

        profilePhotoUrl = docProfileObjectEdit["profile_photo_url"];
        isEditScreen = true;
      } else
        // ignore: curly_braces_in_flow_control_structures
        () {};
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  circleAvatarImage() {
    var bgImage;

    if (profilePhotoUrl != null) {
      bgImage = NetworkImage(profilePhotoUrl!);
    } else if (picPhoto != null) {
      bgImage = FileImage(picPhoto!) as ImageProvider;
    } else
      (bgImage = AssetImage("assets/images/doctor_profile_icon.png"));

    return bgImage;
  }

  checkimage(BuildContext context) {
    context.read<Providers>().showConfirmImage(true);
  }

  loadingTrue() {
    setState(() => isLoading = true);
  }

  loadingFalse() {
    setState(() => isLoading = false);
  }

  checkValidation(context, height, width) {}

  Future submitToDatabase(context, height, width) async {
    try {
      checkimage(context);
      String? capFirstName = toBeginningOfSentenceCase(first_name.text);
      String? capLastName = toBeginningOfSentenceCase(last_name.text);
      final path =
          'doctor_profile_photos/${capFirstName! + "_" + capLastName! + "_" + mobile_number.text}';
      final photoReference = FirebaseStorage.instance.ref().child(path);

      if (isPhotoPicked == true) {
        uploadTask = photoReference.putFile(picPhoto!);

        var snapshot = await uploadTask!.whenComplete(() {});
        profilePhotoUrl = await snapshot.ref.getDownloadURL();
      }

      final docProfile = FirebaseFirestore.instance
          .collection('doctors_profile')
          .doc(mobile_number.text);

      // final url = Uri.parse(
      //     'https://gpprofiler-default-rtdb.asia-southeast1.firebasedatabase.app/doctors_profile.json');
      // http.post(
      //   url,
      // body: json.encode(
      final json_data = {
        "mobile_number": mobile_number.text,
        "first_name": toBeginningOfSentenceCase(first_name.text),
        "last_name": toBeginningOfSentenceCase(last_name.text),
        "address_line1": toBeginningOfSentenceCase(
          address_building_street.text,
        ),
        "city": toBeginningOfSentenceCase(address_city.text),
        "state": address_state.text,
        "pincode": address_pincode.text,
        "email": profile_email.text,
        "category": profile_category.text,
        "gender": profile_gender.text,
        "speciality": profile_speciality.text,
        "profile_photo_url": profilePhotoUrl,
      };

      await docProfile.set(json_data);
      // ),
      // );
      // .then((response) => print(json.decode(response.body)));
    } finally {
      Navigator.of(context).pop(context);
    }
  }

  submitButton(context, height, width) {
    return NeumorphicButton(
      margin: const EdgeInsets.only(top: 15),
      onPressed: () async {
        final isValid = formKey.currentState!.validate();
        if (!isValid) {
          return formValidatorSnackbar(context, height, width);
        }

        if (picPhoto == null && profilePhotoUrl == null) {
          return photoValidator(context, height, width);
        }
        formKey.currentState!.save();
        loadingTrue();
        if (isEditScreen) {
          await submitToDatabase(context, height, width);
          return;
        } else {
          await restrictRepeatPhoneNumber(mobile_number.text).then((_) async {
            if (docPhoneNum == null) {
              await submitToDatabase(context, height, width);
            }
          });
          loadingFalse();
        }
      },
      child: const Icon(Icons.done, size: 50),
      style: const NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.circle(),
          color: Colors.amber),
    );
  }

  diplayDatabaseError(context, height, width, e) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: <Widget>[
          const Icon(CustomIcon1.attention, color: Colors.amber),
          SizedBox(
            width: 30,
          ),
          Expanded(child: Text("$e")),
        ],
      ),
      action: SnackBarAction(
        label: "Retry",
        textColor: Colors.amber,
        onPressed: () async {
          final isValid = formKey.currentState!.validate();
          if (!isValid) {
            return formValidatorSnackbar(context, height, width);
          }

          if (picPhoto == null && profilePhotoUrl == null) {
            return photoValidator(context, height, width);
          }
          formKey.currentState!.save();
          loadingTrue();
          if (isEditScreen) {
            await submitToDatabase(context, height, width);
            return;
          } else {
            await restrictRepeatPhoneNumber(mobile_number.text).then((_) async {
              if (docPhoneNum == null) {
                await submitToDatabase(context, height, width);
              }
            });
            loadingFalse();
          }
        },
      ),
    ));
  }

  photoValidator(context, height, width) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: <Widget>[
          const Icon(CustomIcon1.attention, color: Colors.amber),
          SizedBox(
            width: 30,
          ),
          Expanded(child: Text("Please Select a Photo")),
        ],
      ),
      action: SnackBarAction(
        label: "Add Photo",
        textColor: Colors.amber,
        onPressed: () {
          photpicker_bottom_modal_sheet(context, height, width);
        },
      ),
    ));
  }

  formValidatorSnackbar(context, height, width) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: <Widget>[
          const Icon(CustomIcon1.attention, color: Colors.amber),
          SizedBox(
            width: 30,
          ),
          Expanded(child: Text("Please fill all the required feilds")),
        ],
      ),
    ));
  }

  Future photoPicker(ImageSource source, height, width) async {
    try {
      final picImage = await ImagePicker().pickImage(source: source);
      if (picImage == null) {
        return null;
      }
      isPhotoPicked = true;
      final imageLocation = File(picImage.path);
      profilePhotoUrl = null;
      setState(() {
        this.picPhoto = imageLocation;
      });
    } on PlatformException catch (ep) {
      diplayDatabaseError(context, height, width, ep);
    }
  }

  // ignore: non_constant_identifier_names
  photpicker_bottom_modal_sheet(BuildContext context, height, width) {
    return showModalBottomSheet(
        context: context,
        builder: (_) {
          return Container(
            height: height * 0.15,
            width: width,
            margin: EdgeInsets.symmetric(horizontal: 0, vertical: 30),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Please Select a Photo",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF363f93),
                        fontFamily: "Helvetica"),
                  ),
                  SizedBox(height: height * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextButton.icon(
                        onPressed: () {
                          photoPicker(ImageSource.camera, height, width);
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.camera_alt,
                            size: 50, color: Colors.amber),
                        label: Text(
                          "Camera",
                          style: TextStyle(
                            color: Color(0xFF363f93),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Helvetica",
                          ),
                        ),
                      ),
                      SizedBox(width: width * 0.2),
                      TextButton.icon(
                        onPressed: () {
                          photoPicker(ImageSource.gallery, height, width);
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.amber,
                        ),
                        label: Text(
                          "Gallery",
                          style: TextStyle(
                              color: Color(0xFF363f93),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Helvetica"),
                        ),
                      ),
                    ],
                  )
                ]),
          );
        });
  }

  textInput({
    field_name,
    controller,
    nodeName,
    nextnnodeName,
    errorTextField,
    astrick,
  }) {
    if (astrick == true) {
      return TextFormField(
        cursorColor: Colors.amber,
        validator: RequiredValidator(errorText: errorTextField),
        decoration: InputDecoration(
          label: Row(
            children: [
              Text(field_name),
              Text(
                "*",
                style: TextStyle(color: Colors.red),
              ),
              Padding(
                padding: EdgeInsets.all(3.0),
              ),
            ],
          ),
        ),
        controller: controller,
        onChanged: (value) {
          value = controller.text;
        },
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(nextnnodeName);
        },
        focusNode: nodeName,
      );
    } else {
      return TextFormField(
        cursorColor: Colors.amber,
        decoration: InputDecoration(
          label: Row(
            children: [
              Text(field_name),
              Padding(
                padding: EdgeInsets.all(3.0),
              ),
            ],
          ),
        ),
        controller: controller,
        onChanged: (value) {
          value = controller.text;
        },
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(nextnnodeName);
        },
        focusNode: nodeName,
      );
    }
  }

  final state_list = [
    "Andaman and Nicobar",
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam" "Bihar",
    "Chandigarh",
    "Chhattisgarh",
    "Dadra and Nagar Haveli",
    "Daman and Diu",
    "Delhi",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal" "Pradesh",
    "Jammu and Kashmir",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Ladakh",
    "Lakshadweep",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Orissa",
    "Puducherry",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal"
  ];

  final category_list = ["A", "A+", "B", "B+", "C", "D", "D1", "D2"];

  final gender_list = ["Male", "Female"];

  final speciality_list = [
    "Cardiologist",
    "Dentist",
    "Dermatologist",
    "Diabetologist",
    "ENT (Otolaryngologists)",
    "Gastroenterologist",
    "General Surgeon",
    "GP (General Practitioner)",
    "Gynecologist",
    "MBBS",
    "Neurologist (Neuro Physician)",
    "Onco Surgeon",
    "Ophthalmologist",
    "Orthopedic",
    "Pathologist",
    "Pediatrician",
    "PHY (Physical Medicine and Rehabilitation Physician)",
    "       ",
    "PHYSIO (Physical Therapists)",
    "Psychiatrist",
    "Psychologist",
    "Urologist",
  ];

  final formKey = GlobalKey<FormState>(); //key for form

  final mobile_number = TextEditingController();
  final first_name = TextEditingController();
  final last_name = TextEditingController();
  final address_building_street = TextEditingController();
  final address_city = TextEditingController();
  final address_state = TextEditingController();
  final address_pincode = TextEditingController();
  final profile_email = TextEditingController();
  final profile_category = TextEditingController();
  final profile_gender = TextEditingController();
  final profile_speciality = TextEditingController();

  FocusNode nodeMobileNumber = FocusNode();
  FocusNode nodeFirstName = FocusNode();
  FocusNode nodeLastName = FocusNode();
  FocusNode nodeAddressBuildingStreet = FocusNode();
  FocusNode nodeAddressCity = FocusNode();
  FocusNode nodeAddressState = FocusNode();
  FocusNode nodeAddressPincode = FocusNode();
  FocusNode nodeProfileEmail = FocusNode();
  FocusNode nodeProfileCategory = FocusNode();
  FocusNode nodeProfileGender = FocusNode();
  FocusNode nodeProfileSpeciality = FocusNode();

  @override
  void dispose() {
    mobile_number.dispose();
    first_name.dispose();
    last_name.dispose();
    address_building_street.dispose();
    address_city.dispose();
    address_state.dispose();
    address_pincode.dispose();
    profile_email.dispose();
    profile_category.dispose();
    profile_gender.dispose();
    profile_speciality.dispose();
    nodeMobileNumber.dispose();
    nodeFirstName.dispose();
    nodeLastName.dispose();
    nodeAddressBuildingStreet.dispose();
    nodeAddressCity.dispose();
    nodeAddressState.dispose();
    nodeAddressPincode.dispose();
    nodeProfileEmail.dispose();
    nodeProfileCategory.dispose();
    nodeProfileGender.dispose();
    nodeProfileSpeciality.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.amber),
      ),
      backgroundColor: const Color(0xFFffffff),
      body: isLoading
          ? SpinKitCircle(
              size: 140,
              itemBuilder: (context, index) {
                final colors = [
                  Color(0xff135da1),
                  Color(0xffd2ac67),
                  Color(0xff8d302c),
                  Color(0xfff5a04d),
                  Color(0xfffa3238e),
                  Color(0xfffffcb08),
                  Color(0xff54a276),
                  Color(0xffa5c3d1),
                  Color(0xfff6adcd),
                  Color(0xffd7cb70),
                  Color(0xffceb1c0),
                  Color(0xffed1c24),
                ];
                final color = colors[index % colors.length];
                return DecoratedBox(
                    decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ));
              },
            )
          : Container(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: Form(
                key: formKey, //key for form
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          children: <Widget>[
                            CircleAvatar(
                              backgroundImage: circleAvatarImage(),
                              radius: width * 0.200,
                            ),
                            Positioned(
                                child: InkWell(
                                    child: Icon(Icons.camera_alt,
                                        color: Colors.red, size: height * 0.05),
                                    onTap: () {
                                      photpicker_bottom_modal_sheet(
                                          context, height, width);
                                    }),
                                bottom: 0,
                                right: 0),
                          ],
                        ),
                      ),
                      SizedBox(height: height * 0.04),
                      const Text(
                        "Please Enter Doctor's Name and Number",
                        style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF363f93),
                            fontWeight: FontWeight.bold),
                      ),
                      // SizedBox(
                      //   height: height * 0.01,
                      // ),
                      TextFormField(
                          cursorColor: Colors.amber,
                          decoration: InputDecoration(
                            label: Row(
                              children: const [
                                Text("Mobile Number"),
                                Text(
                                  "*",
                                  style: TextStyle(color: Colors.red),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(3.0),
                                ),
                              ],
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          controller: mobile_number,
                          focusNode: nodeMobileNumber,
                          onChanged: (value) {
                            value = mobile_number.text;
                            if (isEditScreen == false) {
                              mobileNumberOnSubmit();
                            }
                          },
                          onFieldSubmitted: (_) {
                            if (isEditScreen == false) {
                              mobileNumberOnSubmit();
                            }
                          },
                          maxLength: 10,
                          validator: MinLengthValidator(10,
                              errorText: 'Please Check the Phone Number')),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: textInput(
                                controller: first_name,
                                errorTextField: "First Name is Required",
                                field_name: "First Name",
                                nextnnodeName: nodeLastName,
                                nodeName: nodeFirstName,
                                astrick: true),
                          ),
                          SizedBox(
                            width: width * 0.07,
                          ),
                          Expanded(
                            child: textInput(
                                controller: last_name,
                                errorTextField: "Last Name is Required",
                                field_name: "Last Name",
                                nextnnodeName: nodeAddressBuildingStreet,
                                nodeName: nodeLastName,
                                astrick: true),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * 0.05,
                      ),
                      const Text(
                        "Address",
                        style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF363f93),
                            fontWeight: FontWeight.bold),
                      ),
                      textInput(
                          controller: address_building_street,
                          errorTextField: "This Field is Required",
                          field_name: "Building / Street",
                          nextnnodeName: nodeAddressCity,
                          nodeName: nodeAddressBuildingStreet,
                          astrick: true),
                      textInput(
                          controller: address_city,
                          field_name: "City",
                          nextnnodeName: nodeAddressState,
                          nodeName: nodeAddressCity,
                          astrick: false),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: defaultState,
                              validator: (value) {
                                if (value == null) {
                                  return "Please Select a State";
                                }
                              },
                              autovalidateMode: AutovalidateMode.disabled,
                              items: state_list
                                  .map((state) => DropdownMenuItem(
                                        child: Container(
                                            width: width * 0.3,
                                            child: Text(state)),
                                        value: state,
                                      ))
                                  .toList(),
                              onChanged: (state) {
                                address_state.text = state!;
                                defaultState = address_state.text;
                                FocusScope.of(context)
                                    .requestFocus(nodeAddressPincode);
                              },
                              decoration: InputDecoration(
                                label: Row(
                                  children: [
                                    Text("State"),
                                    Text(
                                      "*",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(3.0),
                                    ),
                                  ],
                                ),
                              ),
                              focusNode: nodeAddressState,
                            ),
                          ),
                          SizedBox(
                            width: width * 0.07,
                          ),
                          Expanded(
                            child: TextFormField(
                                decoration: InputDecoration(
                                  label: Row(
                                    children: const [
                                      Text("Pincode"),
                                      Text(
                                        "*",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(3.0),
                                      ),
                                    ],
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                controller: address_pincode,
                                onChanged: (value) {
                                  value = address_pincode.text;
                                },
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(nodeProfileEmail);
                                },
                                maxLength: 6,
                                validator: MinLengthValidator(6,
                                    errorText: 'Please Check the Pincode'),
                                focusNode: nodeAddressPincode),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * 0.05,
                      ),
                      const Text(
                        "Doctor's Profile Details",
                        style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF363f93),
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              cursorColor: Colors.amber,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                label: Row(
                                  children: [
                                    Text("Email"),
                                    Padding(
                                      padding: EdgeInsets.all(3.0),
                                    ),
                                  ],
                                ),
                              ),
                              controller: profile_email,
                              onChanged: (value) {
                                value = profile_email.text;
                              },
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(nodeProfileCategory);
                              },
                              focusNode: nodeProfileEmail,
                              validator: EmailValidator(
                                  errorText: "Please Check Email Format"),
                            ),
                          ),
                          SizedBox(
                            width: width * 0.07,
                          ),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: defaultCategory,
                              items: category_list
                                  .map((category) => DropdownMenuItem(
                                        child: Container(
                                            width: width * 0.3,
                                            child: Text(category)),
                                        value: category,
                                      ))
                                  .toList(),
                              onChanged: (category) {
                                profile_category.text = category!;
                                defaultCategory = profile_category.text;
                                FocusScope.of(context)
                                    .requestFocus(nodeProfileGender);
                              },
                              decoration: InputDecoration(
                                label: Row(
                                  children: [
                                    Text("Category"),
                                    Padding(
                                      padding: EdgeInsets.all(3.0),
                                    ),
                                  ],
                                ),
                              ),
                              focusNode: nodeProfileCategory,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: defaultGender,
                              items: gender_list
                                  .map((gender) => DropdownMenuItem(
                                        child: Container(
                                            width: width * 0.3,
                                            child: Text(gender)),
                                        value: gender,
                                      ))
                                  .toList(),
                              onChanged: (gender) {
                                profile_gender.text = gender!;
                                defaultGender = profile_gender.text;
                                FocusScope.of(context)
                                    .requestFocus(nodeProfileSpeciality);
                              },
                              decoration: InputDecoration(
                                label: Row(
                                  children: [
                                    Text("Gender"),
                                    Padding(
                                      padding: EdgeInsets.all(3.0),
                                    ),
                                  ],
                                ),
                              ),
                              focusNode: nodeProfileGender,
                            ),
                          ),
                          SizedBox(
                            width: width * 0.07,
                          ),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: defaultSpeciality,
                              items: speciality_list
                                  .map((speciality) => DropdownMenuItem(
                                        child: Container(
                                            width: width * 0.3,
                                            child: Text(speciality)),
                                        value: speciality,
                                      ))
                                  .toList(),
                              onChanged: (speciality) async {
                                profile_speciality.text = speciality!;
                                defaultSpeciality = profile_speciality.text;
                                if (formKey.currentState!.validate()) ;

                                final isValid =
                                    formKey.currentState!.validate();
                                if (!isValid) {
                                  return formValidatorSnackbar(
                                      context, height, width);
                                }

                                if (picPhoto == null &&
                                    profilePhotoUrl == null) {
                                  return photoValidator(context, height, width);
                                }
                                formKey.currentState!.save();
                                loadingTrue();
                                if (isEditScreen) {
                                  await submitToDatabase(
                                      context, height, width);
                                  return;
                                } else {
                                  await restrictRepeatPhoneNumber(
                                          mobile_number.text)
                                      .then((_) async {
                                    if (docPhoneNum == null) {
                                      await submitToDatabase(
                                          context, height, width);
                                    }
                                  });
                                  loadingFalse();
                                }
                              },
                              decoration: InputDecoration(
                                label: Row(
                                  children: [
                                    Text("Speciality"),
                                    Padding(
                                      padding: EdgeInsets.all(3.0),
                                    ),
                                  ],
                                ),
                              ),
                              focusNode: nodeProfileSpeciality,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: submitButton(context, height, width),
    );
  }
}
