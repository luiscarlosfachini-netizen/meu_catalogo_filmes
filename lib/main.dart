import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

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
  final List<String> _filmes = [];
  final List<String> _series = [];

  final _tituloController = TextEditingController();
  String _tipoSelecionado = 'Filme';

  void _adicionarItem() {
    _tituloController.clear();
    _tipoSelecionado = 'Filme';

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
                          _filmes.sort(
                            (a, b) =>
                                a.toLowerCase().compareTo(b.toLowerCase()),
                          );
                        } else {
                          _series.add(titulo);
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

  // Função para importar arquivo em tabela (.csv)
  Future<void> _importarTabela() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
      );

      if (result != null && result.files.single.path != null) {
        final input = File(result.files.single.path!).openRead();
        final fields = await input
            .transform(CsvToListConverter(fieldDelimiter: ','))
            .toList();

        int adicionados = 0;

        setState(() {
          for (var row in fields) {
            if (row.length >= 2) {
              String nome = row[0].toString().trim();
              String tipo = row[1].toString().trim().toLowerCase();

              // Pula linha de cabeçalho (se houver)
              if (nome.toLowerCase() == 'nome' ||
                  nome.toLowerCase() == 'titulo') {
                continue;
              }

              if (nome.isNotEmpty) {
                if (tipo.contains('serie') ||
                    tipo.contains('série') ||
                    tipo == 'tv') {
                  if (!_series.contains(nome)) {
                    _series.add(nome);
                    adicionados++;
                  }
                } else {
                  if (!_filmes.contains(nome)) {
                    _filmes.add(nome);
                    adicionados++;
                  }
                }
              }
            }
          }

          _filmes.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
          _series.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sucesso! $adicionados itens importados.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Erro ao ler a tabela. Verifique o formato do arquivo.',
            ),
          ),
        );
      }
    }
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
          actions: [
            IconButton(
              icon: const Icon(Icons.file_upload_outlined),
              tooltip: 'Importar Tabela (.csv)',
              onPressed: _importarTabela,
            ),
          ],
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
              'Nenhum filme cadastrado ainda!\nClique em + para adicionar ou no ícone de importar.',
            ),
            _construirLista(
              _series,
              Icons.tv,
              'Nenhuma série cadastrada ainda!\nClique em + para adicionar ou no ícone de importar.',
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
