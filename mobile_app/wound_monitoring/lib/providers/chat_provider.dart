import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<dynamic, dynamic> map) {
    return ChatMessage(
      text: map['text'],
      isUser: map['isUser'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isGenerating;
  final String currentStreamingResponse;

  ChatState({
    this.messages = const [],
    this.isGenerating = false,
    this.currentStreamingResponse = '',
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isGenerating,
    String? currentStreamingResponse,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isGenerating: isGenerating ?? this.isGenerating,
      currentStreamingResponse: currentStreamingResponse ?? this.currentStreamingResponse,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(ChatState()) {
    _loadHistory();
  }

  void _loadHistory() {
    final box = Hive.box('chatHistory');
    final history = box.get('messages', defaultValue: []) as List;
    final messages = history.map((e) => ChatMessage.fromMap(Map.from(e))).toList();
    
    if (messages.isEmpty) {
      // Add initial greeting based on requested UI
      final greeting = ChatMessage(
        text: "Hello Sarah. I'm your local AI Wound Care Assistant. How can I help you today?",
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(messages: [greeting]);
    } else {
      state = state.copyWith(messages: messages);
    }
  }

  void _saveHistory() {
    final box = Hive.box('chatHistory');
    final serialized = state.messages.map((e) => e.toMap()).toList();
    box.put('messages', serialized);
  }

  void clearChat() {
    state = ChatState(messages: []);
    _saveHistory();
    _loadHistory();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isGenerating) return;

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isGenerating: true,
      currentStreamingResponse: '',
    );

    // Simulate LLM Context Injection and Generation
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Determine response based on input
    String fullResponse = "I'm analyzing your latest scan. ";
    if (text.toLowerCase().contains("explain")) {
      fullResponse = "Your latest scan indicates predominantly granulation tissue, meaning the wound is healing well. However, due to its depth, the infection risk remains at a moderate 34%.";
    } else if (text.toLowerCase().contains("care")) {
      fullResponse = "Keep the area clean and change the dressing daily as prescribed. Avoid putting direct pressure on the wound. Consult your doctor if redness spreads.";
    } else if (text.toLowerCase().contains("better")) {
      fullResponse = "Yes! The wound area has reduced from 24.5 cm² on Day 1 to 12.4 cm² today. The infection risk score is also trending downwards.";
    } else if (text.toLowerCase().contains("doctor")) {
      fullResponse = "You should see a doctor immediately if you notice severe pain, excessive swelling, a foul odor, or if you develop a fever. Otherwise, keep your scheduled check-up next week.";
    } else {
      fullResponse = "I process information based on your latest scan (Area: 12.4 cm², Risk: Moderate). How else can I assist you with your wound care?";
    }

    // Simulate Token Stream
    final words = fullResponse.split(' ');
    String currentStream = '';
    
    for (int i = 0; i < words.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100)); // Token delay
      currentStream += (i == 0 ? '' : ' ') + words[i];
      state = state.copyWith(currentStreamingResponse: currentStream);
    }

    final aiMessage = ChatMessage(
      text: fullResponse,
      isUser: false,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, aiMessage],
      isGenerating: false,
      currentStreamingResponse: '',
    );

    _saveHistory();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
