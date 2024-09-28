import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test_app/constants/routes.dart';
import 'package:test_app/firebase_options.dart';
import 'package:test_app/views/login_view.dart';
import 'package:test_app/views/register_view.dart';
import 'package:test_app/views/verify_email_view.dart';
// import 'dart:developer' as devtools show log;


//Learning asynchronous operation (stream and future)
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute : (context) => const RegisterView(),
        notesRoutes : (context) => const NotesView()
      },
    ),);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
                    options: DefaultFirebaseOptions.currentPlatform,
                  ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;

            if (user != null){
              if(user.emailVerified){
                return const NotesView();
              }else{
                return const VerifyEmailView();
              }
            }else{
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator();
          }
        },
    );
  }
}

enum MenuAction {
  logout
}

// To create the Main UI of the application
class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main UI'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout){
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route)=>false);
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log Out'),
                ),
              ];
            },
          ),
        ],
      ),
      body: const Text('Hello World'),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context){
  return showDialog<bool>(context: context, builder: (context) {
    return AlertDialog(
      title: const Text('Sign out'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(onPressed: (){
          Navigator.of(context).pop(false);
        }, child: const Text('Cancel'),
        ),

        TextButton(onPressed: (){
          Navigator.of(context).pop(true);
        }, child: const Text('Log out'),
        )
      ],
    );
  },).then((value)=>value?? false);
}




// void test() async{
//   // final result = await futureFunction(10);
//   // print(result);

//   // await for ( final value in getName()){
//   //   print(value);
//   // }

//   for (final value in getOneTwoThree()){
//     print(value);
//   }

//   final names = Pair('foo',20);
//   print(names);
// }

// Future<int> futureFunction(int a){
//   return Future.delayed(const Duration(seconds: 3),()=>a*2);
// }

// Stream<String> getName() {
//   // return Stream.value('Ali');
//   return Stream.periodic(const Duration(seconds: 1),(value)=>'Foo');
// }

// //Generators function
// Iterable<int> getOneTwoThree() sync* {
//   yield 1;
//   yield 2;
// }

// // Generics - to avoid re-writting similar code
// class Pair<A,B>{
//   final A value1;
//   final B value2;
//   Pair(this.value1,  this.value2);
// }


