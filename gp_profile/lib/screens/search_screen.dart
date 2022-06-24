import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:gp_profile/screens/add_gp_screen.dart';
import 'package:provider/provider.dart';
import '../customicons/custom_icons.dart';
import '../providers/providers.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:firebase_core/firebase_core.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search_screen';
  static String heroTag = "search_screen";
  SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isPressed = false;
  bool isPressedSearchField = false;
  bool isLoading = false;
  final getSearchInput = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var textInput;

  loadingTrue() {
    setState(() => isLoading = true);
  }

  loadingFalse() {
    setState(() => isLoading = false);
  }

  Widget topHeader() {
    return Text(
      "Please Enter the Doctors Phone Number",
      style: TextStyle(
        color: Color(0xFF363f93),
        fontFamily: "Helvetica",
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  spaceBetween(height, value) {
    return SizedBox(
      height: height * value,
    );
  }

  searchBar(
      {height,
      width,
      backgroundcolor,
      button_blur_searchBar,
      button_offset_searchBar}) {
    return Listener(
      onPointerUp: (_) {
        setState(() {
          isPressedSearchField = false;
        });
      },
      onPointerDown: (_) {
        setState(() {
          isPressedSearchField = true;
        });
      },
      child: AnimatedContainer(
        key: formKey,
        duration: Duration(milliseconds: 100),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: backgroundcolor,
            boxShadow: [
              BoxShadow(
                  blurRadius: button_blur_searchBar,
                  offset: -button_offset_searchBar,
                  color: Colors.white,
                  inset: isPressedSearchField),
              BoxShadow(
                  blurRadius: button_blur_searchBar,
                  offset: button_offset_searchBar,
                  color: Color(0xffa7a9af),
                  inset: isPressedSearchField)
            ]),
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                ),
                child: TextFormField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                  ],
                  keyboardType: TextInputType.number,
                  controller: getSearchInput,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  cursorColor: Colors.amber,
                  validator: MinLengthValidator(10,
                      errorText: 'Please Check the Phone Number'),
                  onChanged: (value) {
                    value = getSearchInput.text;
                  },
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 17),
                    hintText: 'Search already existing Doctors',
                    suffixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                  ),
                ),
              ),
            ],
          ),
          height: height * 0.1,
          width: width * 0.9,
        ),
      ),
    );
  }

  alertValidator(alterType, alterText) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(alterType),
        content: Text(alterText),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future searchDatabase() async {
    await context.read<Providers>().editDoctorHTTPRequest(getSearchInput.text);
  }

  validateSearchInput() {
    if (getSearchInput.text == "") {
      textInput = "Wrong";
      return alertValidator(
          "No Input Error", "Please Enter a Vaild Phone Number");
    }
    if (getSearchInput.text.length < 10) {
      textInput = "Wrong";
      return alertValidator("Entered Number Is Less Than 10 Characters",
          "Please Enter a Correct Phone Number");
    }
  }

  searchButton({
    required BuildContext context,
    backgroundcolor,
    button_blur_button,
    button_offset_button,
    height,
    width,
  }) {
    return Listener(
      onPointerUp: (_) async {
        setState(
          () {
            isPressed = false;
          },
        );
      },
      onPointerDown: (_) async {
        textInput = getSearchInput.text;
        loadingTrue();
        setState(() {
          isPressed = true;
        });
        validateSearchInput();
        if (textInput != "Wrong") {
          await searchDatabase().then((value) {
            loadingFalse();

            if (context.read<Providers>().docProfileObject == null) {
              alertValidator("Number Not Found",
                  "This Number is not Registered in the Database");
            }
            if (context.read<Providers>().docProfileObject != null) {
              Navigator.of(context).pushNamed(AddGPScreen.routeName);
            }
          });
        }
        loadingFalse();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: backgroundcolor,
            boxShadow: [
              BoxShadow(
                  blurRadius: button_blur_button,
                  offset: -button_offset_button,
                  color: Colors.white,
                  inset: isPressed),
              BoxShadow(
                  blurRadius: button_blur_button,
                  offset: button_offset_button,
                  color: Color(0xffa7a9af),
                  inset: isPressed)
            ]),
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/search.png"),
              FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Text(
                "Search",
                style: TextStyle(
                  color: Color(0xFF363f93),
                  fontFamily: "Helvetica",
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          height: height * 0.3,
          width: width * 0.6,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final backgroundcolor = Color(0xffe7ecef);
    double button_blur_button = isPressed ? 5.0 : 30.0;
    Offset button_offset_button = isPressed ? Offset(10, 10) : Offset(28, 28);

    double button_blur_searchBar = isPressedSearchField ? 5.0 : 30.0;
    Offset button_offset_searchBar =
        isPressedSearchField ? Offset(10, 10) : Offset(28, 28);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.amber),
      ),
      backgroundColor: backgroundcolor,
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
          : Column(children: [
              topHeader(),
              spaceBetween(height, 0.07),
              searchBar(
                  backgroundcolor: backgroundcolor,
                  button_blur_searchBar: button_blur_searchBar,
                  button_offset_searchBar: button_offset_searchBar,
                  height: height,
                  width: width),
              spaceBetween(height, 0.09),
              searchButton(
                  context: context,
                  backgroundcolor: backgroundcolor,
                  button_blur_button: button_blur_button,
                  button_offset_button: button_offset_button,
                  height: height,
                  width: width),
            ]),
    );
  }
}
