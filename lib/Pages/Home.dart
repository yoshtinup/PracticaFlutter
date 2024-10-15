import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Color(0xFF1A1A1A)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildInfoCard(context), // Solo aquí el InfoCard con los botones
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 12,
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                'assets/logo_universidad.png',
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Universidad Politécnica de Chiapas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Divider(color: Color.fromARGB(255, 122, 123, 103)),
            const SizedBox(height: 10),
            _buildInfoText('Carrera: Ingeniería en Desarrollo Software'),
            _buildInfoText('Materia: PROGRAMACIÓN PARA MÓVILES II'),
            _buildInfoText('Grupo: B'),
            _buildInfoText('Nombre: Yoshtin German Gutierrez Perez'),
            _buildInfoText('Matrícula: 221246'),
            const SizedBox(height: 40),
            _buildActionButtons(context), // Muestra los botones dentro del InfoCard
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _buildMinimalistButton(

          label: 'Iniciar Conversacion Chatbot',
          onPressed: () {
            Navigator.pushNamed(context, '/chat');
          },
        ),
        const SizedBox(height: 16),
        _buildMinimalistButton(
          label: 'Ver Repositorio en GitHub',
          onPressed: () async {
            const url = 'https://github.com/yoshtinup/PracticaFlutter.git';
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url));
            } else {
              throw 'No se pudo abrir $url';
            }
          },
        ),
      ],
    );
  }

  Widget _buildMinimalistButton({
 
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color.fromARGB(255, 224, 224, 224), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 255, 252, 56),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color.fromARGB(255, 255, 229, 57)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }
}
