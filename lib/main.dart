import 'package:flutter/material.dart';
import 'package:tarefas_app/home.dart';
import 'package:localstorage/localstorage.dart';

void main() {

  const app = MaterialApp(

    title: "Lista de Tarefas",
    home: Home(),
  );
  
  WidgetsFlutterBinding.ensureInitialized();
  initLocalStorage().then((value) =>

    runApp(app)
  );

}
