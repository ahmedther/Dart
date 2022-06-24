import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//
import '../animation/fadeanimation.dart';
import './add_gp_screen.dart';
import '../providers/providers.dart';
import 'package:provider/provider.dart';
import '../screens/search_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home_page';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void selectPageAddScreen(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(AddGPScreen.routeName);

    // MaterialPageRoute(builder: (_) {
    //   return AddGPScreen();
    // }));
  }

  /// CURRENT FIREBASE USER
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    var confirmation = context.watch<Providers>().show_confrim_image;

    /// CURRENT WIDTH AND HEIGHT
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    Widget displayimage() {
      if (confirmation == false) {
        return Container(
          margin: const EdgeInsets.only(right: 35, bottom: 20, top: 20),
          decoration: const BoxDecoration(
            image:
                DecorationImage(image: AssetImage("assets/images/logo1.png")),
          ),
          height: h / 4,
          width: w / 1.5,
        );
      } else {
        return Container(
          margin: const EdgeInsets.only(right: 35, bottom: 20, top: 20),
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/confirmation.png")),
          ),
          height: h / 4,
          width: w / 1.5,
        );
      }
    }

    ///
    return Scaffold(
      /// APP BAR
      appBar: AppBar(
        title: const Text("HOME"),
        centerTitle: true,
        actions: <Widget>[
          Row(
            children: [
              IconButton(
                onPressed: () {
                  context.read<Providers>().showConfirmImage(false);
                  Navigator.of(context).pushNamed(SearchScreen.routeName);
                },
                icon: Icon(Icons.search),
              ),
              IconButton(
                onPressed: () {
                  context.read<Providers>().showConfirmImage(false);
                  selectPageAddScreen(context);
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
      body: SizedBox(
        width: w,
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                /// FLUTTER IMAGE
                FadeAnimation(delay: 1, child: displayimage()),

                /// WELCOME TEXT
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: FadeAnimation(
                    delay: 1.5,
                    child: const Text(
                      "Welcome To The DEMO",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 35,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),

                /// SIGN IN TEXT
                FadeAnimation(
                  delay: 2,
                  child: Text(
                    "signed In as: " + user.email!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),

                /// LOG OUT BUTTON
                FadeAnimation(
                  delay: 2.5,
                  child: ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    child: const Text("Log out"),
                  ),
                  // Add Button
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          heroTag: AddGPScreen.heroTag,
          onPressed: () {
            context.read<Providers>().showConfirmImage(false);
            selectPageAddScreen(context);
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.amber),
    );
  }
}
