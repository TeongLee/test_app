// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:test_app/constants/routes.dart';
import 'package:test_app/enums/menu_action.dart';
import 'package:test_app/services/auth/auth_service.dart';
import 'package:test_app/services/crud/notes_service.dart';


// To create the Main UI of the application
class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {

  late final NotesService _notesService;
  // the '!' - null assertion operator means that you are very sure that the nullable variable is not null at here
  String get userEmail => AuthService.firebase().currentUser!.email!;  

  //open the database
  @override
  void initState(){
    _notesService = NotesService();
    // _notesService.open(); 
    super.initState();
  }

  //close the database when dispose
  @override
  void dispose(){
    _notesService = NotesService();
    _notesService.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          IconButton(
          onPressed: (){
            Navigator.pushNamed(context, newNoteRoute);
          },
           icon: const Icon(Icons.add),
          ),

          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout){
                    await AuthService.firebase().logOut();
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
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail), 

        builder: (context,snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.done:
              return StreamBuilder(stream: _notesService.allNotes, 
              builder:  (context,snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                    return const Text('Waiting for all notes....');
                  // case ConnectionState.done:
                  //   // TODO: Handle this case.
                  default:
                    return CircularProgressIndicator();
                }
              }
              );
            default:
              return const CircularProgressIndicator();
          }


          
        }, 
        
      )
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