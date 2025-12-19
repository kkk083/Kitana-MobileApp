import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:ui';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({required this.text, required this.isUser})
      : timestamp = DateTime.now();
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String _username = '';

  // 🌸 Palette chaude et douce
  final Color _deepTerracotta = const Color(0xFFB6745E);
  final Color _warmClay = const Color(0xFFD3A588);
  final Color _mutedRose = const Color(0xFFC99A9A);
  final Color _oliveMoss = const Color(0xFF9BA17B);
  final Color _warmTaupe = const Color(0xFF8C6E63);
  final Color _amberDust = const Color(0xFFC7A16B);
  final Color _backgroundBeige = const Color(0xFFEEE3D6);

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _messages.add(Message(
      text: "Bonjour ! Je suis KINTANA, posez-moi vos questions.",
      isUser: false,
    ));
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Utilisateur';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/auth');
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatResponse(String text) {
    String formatted = text;
    formatted = formatted.replaceAllMapped(
      RegExp(r'\*\*(.*?)\*\*|__(.*?)__'),
      (match) => match.group(1) ?? match.group(2) ?? '',
    );
    formatted = formatted.replaceAllMapped(
      RegExp(r'\*(.*?)\*|_(.*?)_'),
      (match) => match.group(1) ?? match.group(2) ?? '',
    );
    formatted = formatted.replaceAll(
        RegExp(r'^\s*[\*\-\+]\s+', multiLine: true), '• ');
    return formatted.trim();
  }

  Future<void> _sendMessage(String question) async {
    if (question.trim().isEmpty) return;

    setState(() {
      _messages.add(Message(text: question, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final url = Uri.parse("http://127.0.0.1:5000/ask");

      final res = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"question": question}),
          )
          .timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final answer = _formatResponse(data["answer"]);

        setState(() {
          _messages.add(Message(text: answer, isUser: false));
        });
      } else {
        setState(() {
          _messages.add(Message(
            text: "Erreur serveur: ${res.statusCode}",
            isUser: false,
          ));
        });
      }
    } on TimeoutException {
      setState(() {
        _messages.add(Message(
          text: "Le serveur met trop de temps à répondre.",
          isUser: false,
        ));
      });
    } on SocketException {
      setState(() {
        _messages.add(Message(
          text: "Impossible de se connecter au serveur.",
          isUser: false,
        ));
      });
    } catch (e) {
      setState(() {
        _messages.add(Message(
          text: "Erreur: $e",
          isUser: false,
        ));
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _backgroundBeige,
              _warmClay.withOpacity(0.4),
              _mutedRose.withOpacity(0.25),
              _deepTerracotta.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
              ),
              if (_isLoading) _buildLoadingIndicator(),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _warmClay.withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _deepTerracotta.withOpacity(0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: _warmTaupe.withOpacity(0.8),
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          _deepTerracotta,
                          _amberDust,
                          _mutedRose,
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'KINTANA',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 7,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Connecté en tant que $_username',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                        color: _warmTaupe.withOpacity(0.45),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _logout,
                icon: Icon(
                  Icons.logout_rounded,
                  color: _deepTerracotta,
                ),
                tooltip: 'Déconnexion',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 0.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _deepTerracotta.withOpacity(0.4),
                  _amberDust.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            _buildAvatar(_oliveMoss, _warmClay, Icons.auto_awesome_rounded),
          if (!isUser) const SizedBox(width: 12),
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24).copyWith(
                topLeft: isUser
                    ? const Radius.circular(24)
                    : const Radius.circular(6),
                topRight: isUser
                    ? const Radius.circular(6)
                    : const Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isUser
                        ? _deepTerracotta.withOpacity(0.25)
                        : Colors.white.withOpacity(0.25),
                    border: Border.all(
                      color: _warmClay.withOpacity(0.5),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(24).copyWith(
                      topLeft: isUser
                          ? const Radius.circular(24)
                          : const Radius.circular(6),
                      topRight: isUser
                          ? const Radius.circular(6)
                          : const Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _warmTaupe.withOpacity(0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(
                      color: Color(0xFF3D322B),
                      fontSize: 14.5,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 12),
          if (isUser)
            _buildAvatar(_deepTerracotta, _mutedRose, Icons.person_rounded),
        ],
      ),
    );
  }

  Widget _buildAvatar(Color c1, Color c2, IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c1, c2],
        ),
        boxShadow: [
          BoxShadow(
            color: c1.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white.withOpacity(0.9),
        size: 18,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 20),
      child: Row(
        children: [
          _buildAvatar(_oliveMoss, _warmClay, Icons.auto_awesome_rounded),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _warmClay.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(_amberDust),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "En train d'écrire...",
                      style: TextStyle(
                        color: _warmTaupe.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: _warmClay.withOpacity(0.7),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _deepTerracotta.withOpacity(0.25),
                  blurRadius: 32,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Posez votre question...",
                      hintStyle: TextStyle(
                        color: _warmTaupe.withOpacity(0.45),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF3D322B),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                    ),
                    onSubmitted: _sendMessage,
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_deepTerracotta, _amberDust],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _deepTerracotta.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _isLoading ? null : () => _sendMessage(_controller.text),
                    icon: Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white.withOpacity(0.95),
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}