import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test_app/firebase_options.dart';
import 'package:test_app/views/login_view.dart';


//Learning asynchronous operation (stream and future)
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    ),);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
                    options: DefaultFirebaseOptions.currentPlatform,
                  ),
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;

            if (user?.emailVerified ?? false){
              print('You are a verified user!');
            }else{
              print('Please verify your email first....');
            }
            return const Text('Done');
          default:
            return const Text('Loading....');
          }
        },
      ),
    );
  }
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


