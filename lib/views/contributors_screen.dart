import 'package:flutter/material.dart';

class Contributor {
  final String name;
  final String role;
  final String imagePath;

  Contributor({required this.name, required this.role, required this.imagePath});
}

class ContributorsScreen extends StatelessWidget {
  const ContributorsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contributors = [
      Contributor(name: 'Robson Pequeno de Souza', role: 'Coordenador no LAIS', imagePath: 'assets/prof.robson.jpg'),
      Contributor(name: 'José Alberto Souza Paulino', role: 'Pesquisador do NUTES/LAIS', imagePath: 'assets/José Alberto Souza Paulino.jpeg'),
      Contributor(name: 'Aleksandro da Costa Fabrício', role: 'Pesquisador do NUTES/LAIS', imagePath: 'assets/aleksandro.jpg'),
      Contributor(name: 'Wagner Tiburcio Da Silva  Junior', role: 'Estagiário do NUTES/LAIS', imagePath: 'assets/wagner.jpg'),
      Contributor(name: 'Kevin Santos Marques', role: 'Estagiário do NUTES/LAIS', imagePath: 'assets/kevin.jpeg'),
      Contributor(name: 'Fernando de  Paiva Almeida Ferreira', role: 'Estagiário do NUTES/LAIS', imagePath: 'assets/Fernando De Paiva.jpeg'),
      Contributor(name: 'Filippe Marcel dos Santos Lins', role: 'Estagiário do NUTES/LAIS', imagePath: 'assets/Filippe Marcel dos Santos Lins.jpeg'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F8),
      appBar: AppBar(
        title: const Text(
          'Derma SDAC',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF0F0F8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/logo.jpeg'),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: contributors.length,
        itemBuilder: (context, index) {
          final contributor = contributors[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(contributor.imagePath),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contributor.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contributor.role,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
