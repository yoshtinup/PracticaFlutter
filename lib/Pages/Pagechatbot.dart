import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Pagechatbot extends StatefulWidget {
  const Pagechatbot({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<Pagechatbot> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isConnected = true; // Control de conexión
  final String apiKey = 'AIzaSyDlA0kPUOi68Rrpx2RU7GemJDiIGP8eQUU';
  final String apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _checkConnectivity();
    _listenToConnectivityChanges();
  }

  @override
  void dispose() {
    Connectivity().onConnectivityChanged.drain();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  void _listenToConnectivityChanges() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMessages = prefs.getStringList('chat_history') ?? [];
    setState(() {
      _messages.clear();
      _messages.addAll(
        savedMessages.map((msg) => Map<String, String>.from(jsonDecode(msg))).toList(),
      );

      // Mostrar mensaje de bienvenida solo si no hay mensajes
      if (_messages.isEmpty) {
        _messages.add({'sender': 'bot', 'text': '¡Bienvenido a ChatbosGme! ¿Cómo puedo ayudarte hoy?'});
      }
    });
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedMessages = _messages.map((msg) => jsonEncode(msg)).toList();
    await prefs.setStringList('chat_history', encodedMessages);
  }

  Future<String?> _callGeminiAPI(String query) async {
    final messagesForContext = _messages.map((msg) => msg['text']!).toList();
    try {
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': messagesForContext.join('\n') + '\nUser: $query'}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates']?[0]['content']?['parts']?[0]['text'] ?? 'Sin respuesta.';
      } else {
        print('Error: ${response.statusCode}');
        print('Body: ${response.body}');
        return 'Error en la respuesta del servidor.';
      }
    } catch (e) {
      print('Error en la llamada a la API: $e');
      return 'Error de conexión.';
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': message});
      _controller.clear();
    });

    if (_isConnected) {
      final response = await _callGeminiAPI(message);
      if (response != null) {
        setState(() {
          _messages.add({'sender': 'bot', 'text': response});
        });
      }
    } else {
      setState(() {
        _messages.add({'sender': 'bot', 'text': 'No hay conexión a internet. Por favor, intenta más tarde.'});
      });
    }
    
    await _saveChatHistory(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Chatbot'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black, 
        child: Column(
          children: [
            _buildChatHistory(),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHistory() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          final isUserMessage = message['sender'] == 'user';

          return Align(
            alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: isUserMessage ? Colors.yellow : Colors.grey.shade800, 
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                message['text'] ?? '',
                style: TextStyle(
                  color: Colors.white, 
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: Colors.white), 
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                hintStyle: TextStyle(color: Colors.grey), 
                filled: true,
                fillColor: Colors.grey.shade900, 
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _isConnected ? (value) => _sendMessage(value) : null,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            color: _isConnected ? Colors.yellow : Colors.grey,
            onPressed: _isConnected
                ? () => _sendMessage(_controller.text)
                : null,
          ),
        ],
      ),
    );
  }
}
