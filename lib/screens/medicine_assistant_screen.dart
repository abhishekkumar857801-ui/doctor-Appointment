
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MedicineAssistantScreen extends StatefulWidget {
  const MedicineAssistantScreen({super.key});

  @override
  State<MedicineAssistantScreen> createState() =>
      _MedicineAssistantScreenState();
}

class _MedicineAssistantScreenState
    extends State<MedicineAssistantScreen> {
  static const Color primary = Color(0xFF176B87);

  final TextEditingController _messageController =
  TextEditingController();

  final ScrollController _scrollController =
  ScrollController();

  final List<Map<String, dynamic>> _messages = [];

  bool _isLoading = false;
  String _language = 'en';

  String get _welcomeMessage => _language == 'hi'
      ? 'नमस्ते! मैं आपका Medicine Assistant हूँ। '
      'आप मुझसे सामान्य दवा संबंधी प्रश्न पूछ सकते हैं।'
      : 'Hello! I can provide limited general medicine information. '
      'Ask a question or choose one of the examples below.';

  String get _disclaimer => _language == 'hi'
      ? 'यह सीमित सामान्य जानकारी देने वाला सहायक है। यह डॉक्टर '
      'की सलाह, निदान या उपचार का विकल्प नहीं है।'
      : 'This is a limited, rule-based information assistant, '
      'not a doctor or a replacement for professional advice.';

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty || _isLoading) return;

    if (message.length > 1000) {
      _showError(
        _language == 'hi'
            ? 'कृपया 1000 अक्षरों से छोटा संदेश लिखें।'
            : 'Please enter a message of up to 1000 characters.',
      );
      return;
    }

    if (FirebaseAuth.instance.currentUser == null) {
      _showError(
        _language == 'hi'
            ? 'कृपया फिर से लॉगिन करें।'
            : 'Please log in again.',
      );
      return;
    }

    setState(() {
      _messages.add({
        'text': message,
        'isUser': true,
      });
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Local response: no Cloud Function or external AI API.
    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    final result = _getLocalReply(message);

    if (!mounted) return;

    setState(() {
      _messages.add({
        'text': result['text'],
        'isUser': false,
        'emergency': result['emergency'],
      });
      _isLoading = false;
    });

    _scrollToBottom();
  }

  Map<String, dynamic> _getLocalReply(String message) {
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
      'ज्यादा दवा',
      'ज़्यादा दवा',
      'अधिक मात्रा',
    ];

    if (emergencyTerms.any((term) => text.contains(term))) {
      return {
        'emergency': true,
        'text': _language == 'hi'
            ? 'यह आपातकाल हो सकता है। तुरंत स्थानीय आपातकालीन '
            'सेवा या नजदीकी अस्पताल से संपर्क करें। ऑनलाइन '
            'उत्तर की प्रतीक्षा न करें।'
            : 'This may be a medical emergency. Contact your '
            'local emergency service or go to the nearest '
            'emergency department now. Do not wait for an '
            'online response.',
      };
    }

    if (text.contains('paracetamol') ||
        text.contains('acetaminophen') ||
        text.contains('पैरासिटामोल')) {
      return {
        'emergency': false,
        'text': _language == 'hi'
            ? 'पैरासिटामोल का उपयोग दर्द और बुखार कम करने के '
            'लिए किया जाता है। अधिक मात्रा लेने से लिवर को '
            'गंभीर नुकसान हो सकता है। सही उपयोग के लिए डॉक्टर '
            'या फार्मासिस्ट से पूछें।'
            : 'Paracetamol (acetaminophen) is commonly used to '
            'relieve pain and fever. Too much can cause '
            'serious liver damage. Ask a doctor or pharmacist '
            'about safe use.',
      };
    }

    if (text.contains('antibiotic') ||
        text.contains('antibiotics') ||
        text.contains('एंटीबायोटिक')) {
      return {
        'emergency': false,
        'text': _language == 'hi'
            ? 'एंटीबायोटिक कुछ बैक्टीरियल संक्रमणों का इलाज '
            'करती हैं। वे वायरल संक्रमणों, जैसे सामान्य '
            'सर्दी-जुकाम, पर काम नहीं करतीं। इन्हें डॉक्टर '
            'की सलाह के अनुसार ही लें।'
            : 'Antibiotics treat certain bacterial infections. '
            'They do not treat viral illnesses such as the '
            'common cold. Use them only as directed by a '
            'qualified healthcare professional.',
      };
    }

    if (text.contains('side effect') ||
        text.contains('side effects') ||
        text.contains('दुष्प्रभाव')) {
      return {
        'emergency': false,
        'text': _language == 'hi'
            ? 'दवाओं के दुष्प्रभाव दवा और व्यक्ति के अनुसार '
            'अलग हो सकते हैं। दवा का नाम डॉक्टर या फार्मासिस्ट '
            'को दिखाएँ। सांस लेने में कठिनाई या चेहरे अथवा '
            'गले में सूजन होने पर तुरंत आपातकालीन सहायता लें।'
            : 'Side effects vary by medicine and person. Show '
            'the medicine name and packaging to a doctor or '
            'pharmacist. Seek emergency help for difficulty '
            'breathing or swelling of the face or throat.',
      };
    }

    if (text.contains('missed dose') ||
        text.contains('forgot my medicine') ||
        text.contains('खुराक भूल')) {
      return {
        'emergency': false,
        'text': _language == 'hi'
            ? 'छूटी हुई खुराक के निर्देश दवा के अनुसार अलग '
            'होते हैं। दवा का सूचना-पत्र देखें या फार्मासिस्ट '
            'से पूछें। बिना सलाह के दोहरी खुराक न लें।'
            : 'Instructions for a missed dose depend on the '
            'medicine. Check its leaflet or ask a pharmacist. '
            'Do not double a dose unless a healthcare '
            'professional specifically instructs you to.',
      };
    }

    if (text.contains('medicine label') ||
        text.contains('read the label') ||
        text.contains('दवा के लेबल')) {
      return {
        'emergency': false,
        'text': _language == 'hi'
            ? 'दवा के लेबल पर दवा का नाम, उसकी मात्रा, उपयोग '
            'की विधि, समाप्ति तिथि और चेतावनियाँ देखें। '
            'कोई बात स्पष्ट न हो तो फार्मासिस्ट से पूछें।'
            : 'Check the medicine name, strength, directions, '
            'expiry date, and warnings on the label. Ask a '
            'pharmacist if anything is unclear.',
      };
    }

    return {
      'emergency': false,
      'text': _language == 'hi'
          ? 'मैं अभी सीमित सामान्य दवा जानकारी दे सकता हूँ। '
          'दवा का नाम और अपना प्रश्न स्पष्ट करें, या डॉक्टर '
          'अथवा फार्मासिस्ट से सलाह लें। मैं निदान या व्यक्तिगत '
          'खुराक निर्धारित नहीं कर सकता।'
          : 'I currently provide limited, predefined medicine '
          'information. Try asking about paracetamol, '
          'antibiotics, side effects, missed doses, or medicine '
          'labels. I cannot diagnose conditions or prescribe '
          'a personal dosage.',
    };
  }

  void _showError(String message) {
    if (!mounted) return;

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
    if (_isLoading) return;

    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.medication_outlined),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Medicine Assistant',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Clear chat',
            onPressed: _isLoading ? null : _clearChat,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildLanguageSelector(),
            _buildDisclaimer(),
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState()
                  : _buildMessageList(),
            ),
            if (_isLoading) _buildLoadingIndicator(),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      child: Row(
        children: [
          const Icon(Icons.language, color: primary),
          const SizedBox(width: 8),
          const Text(
            'Language',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment<String>(
                value: 'en',
                label: Text('English'),
              ),
              ButtonSegment<String>(
                value: 'hi',
                label: Text('हिंदी'),
              ),
            ],
            selected: {_language},
            onSelectionChanged: _isLoading
                ? null
                : (selection) {
              setState(() {
                _language = selection.first;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: const Color(0xFFFFF3D6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 20,
            color: Colors.brown,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _disclaimer,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Colors.brown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_information_outlined,
                size: 48,
                color: primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'How can I help you?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF17324D),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _welcomeMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 22),
            _suggestionChip(
              _language == 'hi'
                  ? 'पैरासिटामोल क्या है?'
                  : 'What is paracetamol?',
            ),
            const SizedBox(height: 10),
            _suggestionChip(
              _language == 'hi'
                  ? 'एंटीबायोटिक क्या हैं?'
                  : 'What are antibiotics?',
            ),
            const SizedBox(height: 10),
            _suggestionChip(
              _language == 'hi'
                  ? 'दवा के लेबल को कैसे पढ़ें?'
                  : 'How do I read a medicine label?',
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestionChip(String text) {
    return ActionChip(
      avatar: const Icon(
        Icons.chat_bubble_outline,
        size: 18,
        color: primary,
      ),
      label: Text(text),
      onPressed: _isLoading
          ? null
          : () {
        _messageController.text = text;
        _sendMessage();
      },
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isUser = message['isUser'] == true;
        final isEmergency = message['emergency'] == true;
        final text = message['text'] as String? ?? '';

        return Align(
          alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.82,
            ),
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isEmergency
                  ? const Color(0xFFFFE5E5)
                  : isUser
                  ? primary
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isEmergency
                  ? Border.all(color: Colors.red.shade300)
                  : null,
              boxShadow: [
                if (!isUser)
                  const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isEmergency) ...[
                  const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Emergency warning',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: isEmergency
                        ? Colors.red.shade900
                        : isUser
                        ? Colors.white
                        : const Color(0xFF17324D),
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: primary,
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Preparing response...',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 4,
              maxLength: 1000,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: _language == 'hi'
                    ? 'अपना प्रश्न लिखें...'
                    : 'Ask a medicine question...',
                counterText: '',
                filled: true,
                fillColor: const Color(0xFFF4F8FB),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 48,
            width: 48,
            child: IconButton.filled(
              onPressed: _isLoading ? null : _sendMessage,
              style: IconButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey,
              ),
              icon: const Icon(Icons.send_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
