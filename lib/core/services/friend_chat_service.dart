import 'dart:developer' as developer;
import 'package:spots/core/models/friend_chat_message.dart';
import 'package:spots/core/services/message_encryption_service.dart';
import 'package:spots/data/datasources/local/sembast_database.dart';
import 'package:sembast/sembast.dart';
import 'package:uuid/uuid.dart';

/// FriendChatService
/// 
/// Service for 1-on-1 encrypted friend chats.
/// All messages are encrypted with AES-256-GCM before storage.
/// 
/// Philosophy: "Doors, not badges" - Authentic connections through secure communication.
/// Privacy: All messages encrypted on-device, never transmitted unencrypted.
/// 
/// Phase 2.2: Friend Chat Service
class FriendChatService {
  static const String _logName = 'FriendChatService';
  static const String _chatStoreName = 'friend_chat_messages';
  static const String _chatIdPrefix = 'friend_chat_';
  
  final MessageEncryptionService _encryptionService;
  
  FriendChatService({
    MessageEncryptionService? encryptionService,
  }) : _encryptionService = encryptionService ?? AES256GCMEncryptionService();
  
  /// Send an encrypted message to a friend
  /// 
  /// [userId] - Sender's user ID
  /// [friendId] - Recipient's user ID
  /// [message] - Plaintext message to send
  /// 
  /// Returns the created FriendChatMessage
  Future<FriendChatMessage> sendMessage(
    String userId,
    String friendId,
    String message,
  ) async {
    try {
      developer.log('Sending message from $userId to $friendId', name: _logName);
      
      // Generate consistent chat ID (sorted IDs for bidirectional chats)
      final chatId = _generateChatId(userId, friendId);
      
      // Encrypt message
      final encrypted = await _encryptionService.encrypt(message, chatId);
      
      // Create message
      final chatMessage = FriendChatMessage(
        messageId: const Uuid().v4(),
        chatId: chatId,
        senderId: userId,
        recipientId: friendId,
        encryptedContent: encrypted,
        timestamp: DateTime.now(),
        isRead: false,
      );
      
      // Store message
      await _saveMessage(chatMessage);
      
      developer.log('✅ Message sent and saved: ${chatMessage.messageId}', name: _logName);
      return chatMessage;
    } catch (e, stackTrace) {
      developer.log(
        'Error sending message: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Get conversation history between two users
  /// 
  /// [userId] - Current user's ID
  /// [friendId] - Friend's user ID
  /// 
  /// Returns list of messages, most recent first
  Future<List<FriendChatMessage>> getConversationHistory(
    String userId,
    String friendId,
  ) async {
    try {
      final chatId = _generateChatId(userId, friendId);
      final db = await SembastDatabase.database;
      final store = _getChatStore();
      
      final records = await store.find(
        db,
        finder: Finder(
          filter: Filter.equals('chatId', chatId),
          sortOrders: [SortOrder('timestamp', false)], // Most recent first
        ),
      );
      
      return records.map((record) {
        return FriendChatMessage.fromJson(record.value);
      }).toList();
    } catch (e, stackTrace) {
      developer.log(
        'Error getting conversation history: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }
  
  /// Get list of friend conversations for a user
  /// 
  /// [userId] - User's ID
  /// [friendIds] - List of friend IDs to get conversations for
  /// 
  /// Returns list of chat previews, sorted by most recent message
  Future<List<FriendChatPreview>> getFriendsChatList(
    String userId,
    List<String> friendIds, {
    Map<String, String>? friendNames,
    Map<String, String>? friendPhotoUrls,
    Map<String, bool>? friendOnlineStatus,
  }) async {
    try {
      final previews = <FriendChatPreview>[];
      
      for (final friendId in friendIds) {
        final history = await getConversationHistory(userId, friendId);
        
        if (history.isEmpty) {
          // No conversation yet, skip
          continue;
        }
        
        // Get last message
        final lastMessage = history.first;
        
        // Decrypt last message for preview (first 50 chars)
        String? preview;
        try {
          final decrypted = await getDecryptedMessage(lastMessage, userId, friendId);
          preview = decrypted.length > 50 
              ? '${decrypted.substring(0, 50)}...' 
              : decrypted;
        } catch (e) {
          preview = '[Encrypted message]';
        }
        
        // Count unread messages
        final unreadCount = history.where((msg) => 
          !msg.isRead && msg.recipientId == userId
        ).length;
        
        previews.add(FriendChatPreview(
          friendId: friendId,
          friendName: friendNames?[friendId] ?? friendId,
          friendPhotoUrl: friendPhotoUrls?[friendId],
          lastMessagePreview: preview,
          lastMessageTime: lastMessage.timestamp,
          unreadCount: unreadCount,
          isOnline: friendOnlineStatus?[friendId] ?? false,
        ));
      }
      
      // Sort by most recent message
      previews.sort((a, b) {
        if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });
      
      return previews;
    } catch (e, stackTrace) {
      developer.log(
        'Error getting friends chat list: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }
  
  /// Mark messages as read
  /// 
  /// [userId] - User who read the messages
  /// [friendId] - Friend whose messages were read
  /// 
  /// Returns number of messages marked as read
  Future<int> markAsRead(String userId, String friendId) async {
    try {
      final chatId = _generateChatId(userId, friendId);
      final db = await SembastDatabase.database;
      final store = _getChatStore();
      
      // Find all unread messages from friend to user
      final records = await store.find(
        db,
        finder: Finder(
          filter: Filter.and([
            Filter.equals('chatId', chatId),
            Filter.equals('senderId', friendId),
            Filter.equals('recipientId', userId),
            Filter.equals('isRead', false),
          ]),
        ),
      );
      
      int markedCount = 0;
      for (final record in records) {
        final message = FriendChatMessage.fromJson(record.value);
        final updatedMessage = message.copyWith(isRead: true);
        
        await store.record(message.messageId).put(db, updatedMessage.toJson());
        markedCount++;
      }
      
      developer.log('✅ Marked $markedCount messages as read', name: _logName);
      return markedCount;
    } catch (e, stackTrace) {
      developer.log(
        'Error marking messages as read: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return 0;
    }
  }
  
  /// Get decrypted message content
  /// 
  /// [message] - Encrypted message
  /// [userId] - Current user's ID (for chat ID generation)
  /// [friendId] - Friend's ID (for chat ID generation)
  /// 
  /// Returns decrypted message text
  Future<String> getDecryptedMessage(
    FriendChatMessage message,
    String userId,
    String friendId,
  ) async {
    try {
      final chatId = _generateChatId(userId, friendId);
      return await _encryptionService.decrypt(message.encryptedContent, chatId);
    } catch (e, stackTrace) {
      developer.log(
        'Error decrypting message: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return '[Message decryption failed]';
    }
  }
  
  /// Get total unread count across all friend chats
  /// 
  /// [userId] - User's ID
  /// [friendIds] - List of friend IDs
  /// 
  /// Returns total number of unread messages
  Future<int> getTotalUnreadCount(String userId, List<String> friendIds) async {
    try {
      int totalUnread = 0;
      
      for (final friendId in friendIds) {
        final history = await getConversationHistory(userId, friendId);
        totalUnread += history.where((msg) => 
          !msg.isRead && msg.recipientId == userId
        ).length;
      }
      
      return totalUnread;
    } catch (e, stackTrace) {
      developer.log(
        'Error getting total unread count: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return 0;
    }
  }
  
  // ========================================================================
  // PRIVATE METHODS
  // ========================================================================
  
  /// Generate consistent chat ID from two user IDs
  /// Sorts IDs to ensure same chat ID regardless of order
  String _generateChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '$_chatIdPrefix${sortedIds[0]}_${sortedIds[1]}';
  }
  
  /// Save message to storage
  Future<void> _saveMessage(FriendChatMessage message) async {
    try {
      final db = await SembastDatabase.database;
      final store = _getChatStore();
      await store.record(message.messageId).put(db, message.toJson());
    } catch (e, stackTrace) {
      developer.log(
        'Error saving message: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Get chat store
  StoreRef<String, Map<String, dynamic>> _getChatStore() {
    return stringMapStoreFactory.store(_chatStoreName);
  }
}

