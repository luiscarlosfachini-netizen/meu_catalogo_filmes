import 'package:flutter/material.dart';

void main() {
  runApp(const MeuCatalogoApp());
}

class MeuCatalogoApp extends StatelessWidget {
  const MeuCatalogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meus Filmes e Séries',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const TelaPrincipal(),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  // Listas separadas para organizar o catálogo
  final List<String> _filmes = [];
  final List<String> _series = [];

  final _tituloController = TextEditingController();
  String _tipoSelecionado = 'Filme'; // Valor padrão inicial

  void _adicionarItem() {
    _tituloController.clear();
    _tipoSelecionado = 'Filme'; // Reseta a seleção

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Adicionar Novo Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Filme ou Série',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _tipoSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Filme',
                        child: Row(
                          children: [
                            Icon(Icons.movie, color: Colors.deepPurpleAccent),
                            SizedBox(width: 8),
                            Text('Filme'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Série',
                        child: Row(
                          children: [
                            Icon(Icons.tv, color: Colors.deepPurpleAccent),
                            SizedBox(width: 8),
                            Text('Série'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (novoValor) {
                      if (novoValor != null) {
                        setDialogState(() {
                          _tipoSelecionado = novoValor;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final titulo = _tituloController.text.trim();
                    if (titulo.isNotEmpty) {
                      setState(() {
                        if (_tipoSelecionado == 'Filme') {
                          _filmes.add(titulo);
                          // Ordena em ordem alfabética (sem diferenciar maiúsculas/minúsculas)
                          _filmes.sort(
                            (a, b) =>
                                a.toLowerCase().compareTo(b.toLowerCase()),
                          );
                        } else {
                          _series.add(titulo);
                          // Ordena em ordem alfabética
                          _series.sort(
                            (a, b) =>
                                a.toLowerCase().compareTo(b.toLowerCase()),
                          );
                        }
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _construirLista(
    List<String> lista,
    IconData icone,
    String mensagemVazia,
  ) {
    if (lista.isEmpty) {
      return Center(
        child: Text(
          mensagemVazia,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final item = lista[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: Icon(icone, color: Colors.deepPurpleAccent),
            title: Text(
              item,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                setState(() {
                  lista.removeAt(index);
                });
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🍿 Meus Filmes & Séries'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.movie), text: 'Filmes'),
              Tab(icon: Icon(Icons.tv), text: 'Séries'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _construirLista(
              _filmes,
              Icons.movie,
              'Nenhum filme cadastrado ainda!\nClique em + para adicionar.',
            ),
            _construirLista(
              _series,
              Icons.tv,
              'Nenhuma série cadastrada ainda!\nClique em + para adicionar.',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _adicionarItem,
          icon: const Icon(Icons.add),
          label: const Text('Adicionar'),
        ),
      ),
    );
  }
}
