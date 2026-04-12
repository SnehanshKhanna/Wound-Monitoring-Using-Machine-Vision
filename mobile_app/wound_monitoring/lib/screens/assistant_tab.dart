import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../providers/chat_provider.dart';
import 'package:lottie/lottie.dart';

class AssistantTab extends ConsumerStatefulWidget {
  const AssistantTab({super.key});

  @override
  ConsumerState<AssistantTab> createState() => _AssistantTabState();
}

class _AssistantTabState extends ConsumerState<AssistantTab> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isModelLoaded = false;
  
  @override
  void initState() {
    super.initState();
    _simulateModelLoad();
  }

  void _simulateModelLoad() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isModelLoaded = true);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    // Auto-scroll when new message or stream starts
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Assistant'),
            Row(
              children: [
                const Icon(CupertinoIcons.bolt_fill, size: 12, color: AppTheme.accentSafe),
                const SizedBox(width: 4),
                Text(
                  'Running locally · Private',
                  style: TextStyle(fontSize: 10, color: AppTheme.accentSafe.withOpacity(0.8)),
                ),
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.trash),
            onPressed: () => ref.read(chatProvider.notifier).clearChat(),
          )
        ],
      ),
      body: Column(
        children: [
          // Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: AppTheme.surfaceLight,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.wifi_slash, size: 14, color: AppTheme.textSecondary),
                SizedBox(width: 8),
                Text(
                  'Offline — Scan disabled. AI Assistant available.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: !_isModelLoaded
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppTheme.primaryBlue),
                        SizedBox(height: 16),
                        Text('Loading AI model... (42MB)'),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatState.messages.length + (chatState.isGenerating ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chatState.messages.length) {
                        return _buildChatBubble(text: chatState.currentStreamingResponse, isUser: false, isStreaming: true);
                      }
                      final msg = chatState.messages[index];
                      return _buildChatBubble(text: msg.text, isUser: msg.isUser, isStreaming: false);
                    },
                  ),
          ),
          
          if (_isModelLoaded) _buildChatInputArea(ref, chatState.isGenerating),
        ],
      ),
    );
  }

  Widget _buildChatBubble({required String text, required bool isUser, required bool isStreaming}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primaryBlue : AppTheme.surfaceLight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.sparkles, size: 14, color: AppTheme.accentSafe),
                  SizedBox(width: 4),
                  Text('Llama Assistant', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
            ],
            text.isEmpty && isStreaming
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentSafe),
                      ),
                      SizedBox(width: 8),
                      Text('Thinking...'),
                    ],
                  )
                : Text(
                    text + (isStreaming ? ' ▎' : ''), // Blinking cursor effect
                    style: TextStyle(
                      color: isUser ? Colors.white : AppTheme.textPrimary,
                      height: 1.4,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInputArea(WidgetRef ref, bool isGenerating) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.surface,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSuggestionChip('Explain my wound condition', ref),
                  _buildSuggestionChip('What care steps should I follow?', ref),
                  _buildSuggestionChip('Is my wound getting better?', ref),
                  _buildSuggestionChip('When should I see a doctor?', ref),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Ask your AI assistant...',
                      filled: true,
                      fillColor: AppTheme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      suffixIcon: IconButton(
                        icon: const Icon(CupertinoIcons.mic),
                        color: AppTheme.textSecondary,
                        onPressed: () {}, // Mic styling as requested
                      ),
                    ),
                    onSubmitted: (val) {
                      if (val.isNotEmpty) {
                        ref.read(chatProvider.notifier).sendMessage(val);
                        _textController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: isGenerating ? AppTheme.surfaceLight : AppTheme.primaryBlue,
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(CupertinoIcons.arrow_up, color: Colors.white),
                    onPressed: isGenerating ? null : () {
                      final val = _textController.text;
                      if (val.isNotEmpty) {
                        ref.read(chatProvider.notifier).sendMessage(val);
                        _textController.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 12)),
        backgroundColor: AppTheme.surfaceLight,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          ref.read(chatProvider.notifier).sendMessage(text);
        },
      ),
    );
  }
}
