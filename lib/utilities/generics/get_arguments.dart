import 'package:flutter/material.dart'
  show BuildContext, ModalRoute;

//Extensions allow you to add new methods to existing classes
//without modifying the original class itself.
extension GetArguments on BuildContext {
  T? getArgument<T>(){
    final modalRoute = ModalRoute.of(this);
    if (modalRoute != null) {
      final args = modalRoute.settings.arguments;
      if(args != null && args is T){
        return args as T;
      }
    }
    return null;
  }
}