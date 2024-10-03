import 'package:flutter/material.dart';
import 'package:test_app/constants/routes.dart';
import 'package:test_app/services/auth/auth_service.dart';
import 'package:test_app/views/login_view.dart';
import 'package:test_app/views/notes_view.dart';
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
        notesRoutes : (context) => const NotesView(),
        verifyEmailRoutes : (context) => const VerifyEmailView()
      },
    ),);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;

            if (user != null){
              if(user.isEmailVerified){
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


//Basic Notes
//////////////////////////////////
//Enumeration
// enum Person {
//  firstName, lastName, gender, age
//}

///////////////////////////
//Asychronization
// void test() async{
// final result = await futureFunction(10);
// print(result);

// await for ( final value in getName()){
//   print(value);
// }

//   for (final value in getOneTwoThree()){
//     print(value);
//   }

//   final names = Pair('foo',20);
//   print(names);
// }


////////////////////////////////////////////
// Future Function
// Future<int> futureFunction(int a){
//   return Future.delayed(const Duration(seconds: 3),()=>a*2);
// }

////////////////////////////////////////////
//Stream
// Stream<String> getName() {
//   // return Stream.value('Ali');
//   return Stream.periodic(const Duration(seconds: 1),(value)=>'Foo');
// }

////////////////////////////////////////////
//Generators function
// Iterable<int> getOneTwoThree() sync* {
//   yield 1;
//   yield 2;
// }


//////////////////////////////////////////////////
// Generics - to avoid re-writting similar code
// class Pair<A,B>{
//   final A value1;
//   final B value2;
//   Pair(this.value1,  this.value2);
// }

///////////////////////////////////////////////
//Factory constructor
// class Animal {
//   final String name;

//   Animal(this.name); // Regular constructor

//   // Factory constructor
//   factory Animal.createAnimal(String name) {
//     if (name == 'Dog') {
//       return Animal('Dog');  // Create an Animal named Dog
//     } else if (name == 'Cat') {
//       return Animal('Cat');  // Create an Animal named Cat
//     } else {
//       return Animal('Unknown');  // Default to Unknown
//     }
//   }
// }

// void main() {
//   Animal dog = Animal.createAnimal('Dog');
//   Animal cat = Animal.createAnimal('Cat');
//   Animal bird = Animal.createAnimal('Bird');
//   Animal bunny = Animal('Bunny');

//   print(dog.name);  // Output: Dog
//   print(cat.name);  // Output: Cat
//   print(bird.name); // Output: Unknown
//   print(bunny.name); //Output: Bunny
// }
