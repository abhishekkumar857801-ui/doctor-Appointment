
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FloatingMedicineChat extends StatefulWidget {
  const FloatingMedicineChat({super.key});

  @override
  State<FloatingMedicineChat> createState() =>
      _FloatingMedicineChatState();
}

class _FloatingMedicineChatState
    extends State<FloatingMedicineChat> {
  static const Color primary = Color(0xFF176B87);

  final TextEditingController _controller =
  TextEditingController();

  final ScrollController _scrollController =
  ScrollController();

  final List<Map<String, String>> _messages = [];

  bool _isOpen = false;
  bool _isHindi = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getReply(String message) {
    final text = message.toLowerCase();

    final emergencyTerms = [
      'chest pain',
      'difficulty breathing',
      "can't breathe",
      'cannot breathe',
      'unconscious',
      'seizure',
      'overdose',
      'severe bleeding',
      'सीने में दर्द',
      'सांस नहीं',
      'साँस नहीं',
      'बेहोश',
      'दौरा',
      'अधिक मात्रा',
      'ज्यादा दवा',
    ];

    if (emergencyTerms.any((term) => text.contains(term))) {
      return _isHindi
          ? 'यह आपातकाल हो सकता है। तुरंत स्थानीय आपातकालीन '
          'सेवा या नजदीकी अस्पताल से संपर्क करें। ऑनलाइन '
          'जवाब की प्रतीक्षा न करें।'
          : 'This may be an emergency. Contact local emergency '
          'services or go to the nearest emergency department '
          'now. Do not wait for an online response.';
    }

    if (text.contains('paracetamol') ||
        text.contains('acetaminophen') ||
        text.contains('पैरासिटामोल')) {
      return _isHindi
          ? 'पैरासिटामोल का उपयोग दर्द और बुखार कम करने के लिए '
          'किया जाता है। अधिक मात्रा लिवर को नुकसान पहुँचा '
          'सकती है। सुरक्षित उपयोग के लिए डॉक्टर या '
          'फार्मासिस्ट से पूछें।'
          : 'Paracetamol is commonly used to relieve pain and '
          'fever. Taking too much can cause serious liver '
          'damage. Ask a doctor or pharmacist about safe use.';
    }

    if (text.contains('antibiotic') ||
        text.contains('antibiotics') ||
        text.contains('एंटीबायोटिक')) {
      return _isHindi
          ? 'एंटीबायोटिक कुछ बैक्टीरियल संक्रमणों का इलाज '
          'करती हैं, वायरल संक्रमणों का नहीं। इन्हें केवल '
          'डॉक्टर की सलाह के अनुसार लें।'
          : 'Antibiotics treat certain bacterial infections, '
          'not viral illnesses such as the common cold. '
          'Use them only as directed by a qualified '
          'healthcare professional.';
    }

    if (text.contains('side effect') ||
        text.contains('side effects') ||
        text.contains('दुष्प्रभाव')) {
      return _isHindi
          ? 'दवाओं के दुष्प्रभाव अलग-अलग हो सकते हैं। दवा का '
          'नाम और पैकेट डॉक्टर या फार्मासिस्ट को दिखाएँ। '
          'सांस लेने में कठिनाई या चेहरे अथवा गले में सूजन '
          'होने पर तुरंत आपातकालीन सहायता लें।'
          : 'Medicine side effects vary. Show the medicine '
          'packaging to a doctor or pharmacist. Seek '
          'emergency help for difficulty breathing or '
          'swelling of the face or throat.';
    }

    if (text.contains('missed dose') ||
        text.contains('forgot my medicine') ||
        text.contains('खुराक भूल')) {
      return _isHindi
          ? 'छूटी हुई खुराक के निर्देश दवा के अनुसार अलग होते '
          'हैं। दवा का सूचना-पत्र देखें या फार्मासिस्ट से '
          'पूछें। बिना सलाह के दोहरी खुराक न लें।'
          : 'Instructions for a missed dose depend on the '
          'medicine. Check its leaflet or ask a pharmacist. '
          'Do not double a dose unless a healthcare '
          'professional specifically instructs you to.';
    }

    if (text.contains('medicine label') ||
        text.contains('read the label') ||
        text.contains('दवा के लेबल')) {
      return _isHindi
          ? 'दवा के लेबल पर नाम, मात्रा, उपयोग के निर्देश, '
          'समाप्ति तिथि और चेतावनियाँ देखें। कोई बात स्पष्ट '
          'न हो तो फार्मासिस्ट से पूछें।'
          : 'Check the medicine name, strength, directions, '
          'expiry date, and warnings on the label. Ask a '
          'pharmacist if anything is unclear.';
    }

    return _isHindi
        ? 'मैं सीमित सामान्य दवा जानकारी दे सकता हूँ। दवा का '
        'नाम और प्रश्न स्पष्ट करें, या डॉक्टर अथवा '
        'फार्मासिस्ट से सलाह लें। मैं बीमारी का निदान या '
        'व्यक्तिगत खुराक निर्धारित नहीं कर सकता।'
        : 'I provide limited, predefined medicine information. '
        'Try asking about paracetamol, antibiotics, side '
        'effects, missed doses, or medicine labels. I cannot '
        'diagnose conditions or prescribe a personal dosage.';
  }

  void _sendMessage() {
    final text = _controller.text.trim();

    if (text.isEmpty) return;

    if (text.length > 1000) {
      _showError('Please keep your message under 1000 characters.');
      return;
    }

    if (FirebaseAuth.instance.currentUser == null) {
      _showError('Please log in to use the assistant.');
      return;
    }

    setState(() {
      _messages.add({
        'role': 'user',
        'text': text,
      });

      _messages.add({
        'role': 'assistant',
        'text': _getReply(text),
      });

      _controller.clear();
    });

    _scrollToBottom();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    final chatWidth = screenWidth < 380
        ? screenWidth - 32.0
        : 340.0;

    return Stack(
      children: [
        if (_isOpen)
          Positioned(
            right: 16,
            bottom: 82,
            child: Material(
              elevation: 12,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: chatWidth,
                height: 430,
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildLanguageBar(),
                    Expanded(
                      child: _buildMessages(),
                    ),
                    _buildInput(),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Text(
                        'General information only. Not medical advice.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'floatingMedicineAssistant',
            backgroundColor: primary,
            foregroundColor: Colors.white,
            tooltip: _isOpen
                ? 'Close Medicine Assistant'
                : 'Open Medicine Assistant',
            onPressed: () {
              setState(() {
                _isOpen = !_isOpen;
              });
            },
            child: Icon(
              _isOpen
                  ? Icons.close
                  : Icons.chat_bubble_outline,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: primary,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.medical_services_outlined,
              color: primary,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Medicine Assistant',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Clear conversation',
            visualDensity: VisualDensity.compact,
            onPressed: _clearChat,
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 21,
            ),
          ),
          IconButton(
            tooltip: 'Close chat',
            visualDensity: VisualDensity.compact,
            onPressed: () {
              setState(() {
                _isOpen = false;
              });
            },
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageBar() {
    return Container(
      color: const Color(0xFFF4F8FB),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.language,
            color: primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Language',
              style: TextStyle(fontSize: 12),
            ),
          ),
          DropdownButton<bool>(
            value: _isHindi,
            underline: const SizedBox.shrink(),
            isDense: true,
            items: const [
              DropdownMenuItem(
                value: false,
                child: Text(
                  'English',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              DropdownMenuItem(
                value: true,
                child: Text(
                  'हिंदी',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _isHindi = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.chat_outlined,
                size: 40,
                color: primary,
              ),
              const SizedBox(height: 12),
              Text(
                _isHindi
                    ? 'नमस्ते! दवाओं के बारे में सामान्य प्रश्न पूछें।'
                    : 'Hello! Ask a general medicine question.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _isHindi
                    ? 'उदाहरण: पैरासिटामोल क्या है?'
                    : 'Example: What is paracetamol?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final item = _messages[index];
        final isUser = item['role'] == 'user';

        return Align(
          alignment: isUser
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 260,
            ),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: isUser
                  ? primary
                  : const Color(0xFFE8F3F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              item['text'] ?? '',
              style: TextStyle(
                color: isUser
                    ? Colors.white
                    : const Color(0xFF17324D),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              maxLength: 1000,
              minLines: 1,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: _isHindi
                    ? 'अपना प्रश्न लिखें...'
                    : 'Ask a question...',
                counterText: '',
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF4F8FB),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 6),
          IconButton.filled(
            tooltip: 'Send message',
            onPressed: _sendMessage,
            style: IconButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.send, size: 19),
          ),
        ],
      ),
    );
  }
}
