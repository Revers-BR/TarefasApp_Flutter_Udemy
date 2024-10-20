import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

class Home extends StatefulWidget {

  const Home({super.key});

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
 
  List<Map<String, dynamic>> _tarefas  = [];

  final LocalStorage storage = localStorage;

  final TextEditingController _tarefaController = TextEditingController();

  Map<String, dynamic> _ultimaTarefaRemovido = {};

  @override
    void initState() {
      super.initState();

      final jsonString = localStorage.getItem("tarefas");

      if(jsonString != null){

        _tarefas = List<Map<String, dynamic>>.from(json.decode(jsonString));
      }
    }

  void _salvarTarefa() {
    
    final tarefa = <String,dynamic>{
      "tarefa": _tarefaController.text,
      "concluido": false
    };

    _tarefas.add(tarefa);

    _salvarArquivo();

    _tarefaController.text = "";
    
  }

  void _salvarArquivo(){

    localStorage.setItem("tarefas", json.encode(_tarefas));
  }

  Widget criarLista (BuildContext context, int index) {

    final tarefa = _tarefas[index];

    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: ( direction ){

        _ultimaTarefaRemovido = tarefa;

        _tarefas.removeAt(index);              

        final snackBar = SnackBar(
          action: SnackBarAction(
            label: "desfazer", 
            onPressed: (){
              setState(() {
                _tarefas.insert(index, _ultimaTarefaRemovido);
              });

              _salvarArquivo();
            }
          ),
          content: const Text("Tarefa excluido com sucesso!")
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        _salvarArquivo();
      },
      background: Container(
        color: Colors.red,
        padding: const EdgeInsets.all(16),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.delete, 
              color: Colors.white,
            ),
          ],
        ),
      ),
      child: CheckboxListTile(
        title: Text(tarefa["tarefa"] ), 
        value: tarefa["concluido"],
        onChanged: (bool? valorAlterado){
          setState(() {
            _tarefas[index]["concluido"] = valorAlterado;
          });

          _salvarArquivo();
        }
      )
    );
  }

  @override
  Widget build( BuildContext context) {

    return Scaffold(
      
      appBar: AppBar(

        title: const Text("Lista de Tarefas"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add
        ),

        onPressed: (){
          
          showDialog(
            context: context, 
            builder: (BuildContext context){

              return AlertDialog(

                title: const Text('Adicionar tarefas'),
                content: TextField(
                  controller: _tarefaController,
                  decoration: const InputDecoration(
                    
                    label: Text("Nome da Tarefa") 
                  ),
                ),

                actions: [
                  ElevatedButton(
                    onPressed: (){

                      setState(() {
                        _salvarTarefa();                                         
                      });

                      Navigator.pop(context);
                    }, 
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.blue),
                      foregroundColor: MaterialStateProperty.resolveWith((states) => Colors.white)
                    ),
                    child: const Text('Salvar'),
                  ),
                  ElevatedButton(
                    onPressed: (){ Navigator.pop(context); },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.blue),
                      foregroundColor: MaterialStateProperty.resolveWith((states) => Colors.white)
                    ),
                    child: const Text('Cancelar')
                  ),
                ],
              );
            }
          );
        }
      ),

      body: Column(

        children: [

          Expanded(

            child: ListView.builder(

              itemCount: _tarefas.length,
              itemBuilder: criarLista 
            )
          ),
        ],
      ),
    );
  }
}
