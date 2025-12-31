import 'dart:developer' as developer;
import 'package:spots_ai/models/community_chat_message.dart';
import 'package:spots/core/models/community.dart';
import 'package:spots/core/services/message_encryption_service.dart';
import 'package:spots/data/datasources/local/sembast_database.dart';
import 'package:sembast/sembast.dart';
import 'package:uuid/uuid.dart';

/// CommunityChatService
/// 
/// Service for encrypted group chats in communities and clubs.
/// Uses Option A: Shared Group Key encryption (simple and efficient for MVP).
/// 
/// Philosophy: "Doors, not badges" - Authentic community connections through secure group communication.
/// Privacy: All messages encrypted on-device with shared group key.
/// 
/// Phase 2.3: Community Chat Service
/// 
/// **Encryption Implementation (Option A: Shared Group Key):**
/// - Uses `communityId` as recipientId in encryption service
/// - All members use same `communityId`, ensuring shared key access
/// - Encryption service manages key internally
/// - Simple and efficient for MVP
/// 
/// **Future Upgrade Options:**
/// - Option B: Per-Participant Keys (more secure, for future)
/// - Option C: Hybrid Approach (balanced, for future)
/// - Option D: Signal Protocol (most secure, for future)
class CommunityChatService {
  static const String _logName = 'CommunityChatService';
  static const String _chatStoreName = 'community_chat_messages';
  static const String _chatIdPrefix = 'community_chat_';
  
  final MessageEncryptionService _encryptionService;
  
  CommunityChatService({
    MessageEncryptionService? encryptionService,
  }) : _encryptionService = encryptionService ?? AES256GCMEncryptionService();
  
  /// Send an encrypted group message
  /// 
  /// [userId] - Sender's user ID
  /// [communityId] - Community/club ID
  /// [message] - Plaintext message to send
  /// 
  /// Returns the created CommunityChatMessage
  /// 
  /// Throws Exception if user is not a member of the community
  Future<CommunityChatMessage> sendGroupMessage(
    String userId,
    String communityId,
    String message, {
    required Community community, // Pass community to verify membership
  }) async {
    try {
      // Verify user is a member
      if (!community.isMember(userId)) {
        throw Exception('User is not a member of this community');
      }
      
      developer.log('Sending group message from $userId to community $communityId', name: _logName);
      
      final chatId = _generateChatId(communityId);
      
      // Encrypt message with group key
      final encrypted = await _encryptGroupMessage(message, communityId);
      
      // Create message
      final chatMessage = CommunityChatMessage(
        messageId: const Uuid().v4(),
        chatId: chatId,
        communityId: communityId,
        senderId: userId,
        encryptedContent: encrypted,
        timestamp: DateTime.now(),
      );
      
      // Store message
      await _saveMessage(chatMessage);
      
      developer.log('✅ Group message sent and saved: ${chatMessage.messageId}', name: _logName);
      return chatMessage;
    } catch (e, stackTrace) {
      developer.log(
        'Error sending group message: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Get group chat history
  /// 
  /// [communityId] - Community/club ID
  /// 
  /// Returns list of decrypted messages, most recent first
  Future<List<CommunityChatMessage>> getGroupChatHistory(String communityId) async {
    try {
      final chatId = _generateChatId(communityId);
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
        return CommunityChatMessage.fromJson(record.value);
      }).toList();
    } catch (e, stackTrace) {
      developer.log(
        'Error getting group chat history: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }
  
  /// Get user's community chats list
  /// 
  /// [userId] - User's ID
  /// [communities] - List of communities user is a member of
  /// 
  /// Returns list of chat previews, sorted by most recent message
  Future<List<CommunityChatPreview>> getUserCommunitiesChatList(
    String userId,
    List<Community> communities,
  ) async {
    try {
      final previews = <CommunityChatPreview>[];
      
      for (final community in communities) {
        final history = await getGroupChatHistory(community.id);
        
        if (history.isEmpty) {
          // No messages yet, still include in list
          previews.add(CommunityChatPreview(
            communityId: community.id,
            communityName: community.name,
            communityDescription: community.description,
            memberCount: community.memberCount,
            isClub: false, // Would need to check if it's a Club
          ));
          continue;
        }
        
        // Get last message
        final lastMessage = history.first;
        
        // Decrypt last message for preview (first 50 chars)
        String? preview;
        try {
          final decrypted = await getDecryptedMessage(lastMessage, community.id);
          preview = decrypted.length > 50 
              ? '${decrypted.substring(0, 50)}...' 
              : decrypted;
        } catch (e) {
          preview = '[Encrypted message]';
        }
        
        previews.add(CommunityChatPreview(
          communityId: community.id,
          communityName: community.name,
          communityDescription: community.description,
          lastMessagePreview: preview,
          lastMessageTime: lastMessage.timestamp,
          lastSenderName: lastMessage.senderId, // Would need to lookup user name
          memberCount: community.memberCount,
          isClub: false, // Would need to check if it's a Club
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
        'Error getting user communities chat list: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }
  
  /// Add member to chat (when they join community)
  /// 
  /// [communityId] - Community/club ID
  /// [userId] - User ID to add
  /// 
  /// Note: In Option A (Shared Group Key), all members automatically have access
  /// since they all use the same key. This method is for future compatibility.
  Future<void> addMemberToChat(String communityId, String userId) async {
    try {
      developer.log('Adding member $userId to community chat $communityId', name: _logName);
      
      // In Option A, members automatically have access via shared key
      // This method is a placeholder for future upgrade options
      // where individual key management might be needed
      
      developer.log('✅ Member added (shared key access)', name: _logName);
    } catch (e, stackTrace) {
      developer.log(
        'Error adding member to chat: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Remove member from chat (when they leave community)
  /// 
  /// [communityId] - Community/club ID
  /// [userId] - User ID to remove
  /// 
  /// Note: In Option A (Shared Group Key), removing a member doesn't revoke access
  /// since they still have the key. This method is for future compatibility.
  Future<void> removeMemberFromChat(String communityId, String userId) async {
    try {
      developer.log('Removing member $userId from community chat $communityId', name: _logName);
      
      // In Option A, members retain access via shared key
      // This method is a placeholder for future upgrade options
      // where individual key revocation might be needed
      
      developer.log('✅ Member removed (note: shared key access retained in Option A)', name: _logName);
    } catch (e, stackTrace) {
      developer.log(
        'Error removing member from chat: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Get decrypted message content
  /// 
  /// [message] - Encrypted message
  /// [communityId] - Community ID (for key lookup)
  /// 
  /// Returns decrypted message text
  Future<String> getDecryptedMessage(
    CommunityChatMessage message,
    String communityId,
  ) async {
    try {
      return await _decryptGroupMessage(message.encryptedContent, communityId);
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
  
  // ========================================================================
  // PRIVATE METHODS - ENCRYPTION
  // ========================================================================
  
  // Note: For Option A (Shared Group Key), we use communityId as recipientId
  // in the encryption service. This ensures all members use the same key.
  // The encryption service manages the key internally.
  
  /// Encrypt group message with shared group key
  /// 
  /// Uses communityId as recipientId in encryption service.
  /// All members use the same communityId, ensuring shared key access.
  Future<EncryptedMessage> _encryptGroupMessage(
    String message,
    String communityId,
  ) async {
    try {
      // Use communityId as recipientId - encryption service will use same key for all
      // This achieves Option A (Shared Group Key) behavior
      return await _encryptionService.encrypt(message, 'group_$communityId');
    } catch (e, stackTrace) {
      developer.log(
        'Error encrypting group message: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Decrypt group message with shared group key
  /// 
  /// Uses communityId as recipientId in encryption service.
  /// All members use the same communityId, ensuring shared key access.
  Future<String> _decryptGroupMessage(
    EncryptedMessage encrypted,
    String communityId,
  ) async {
    try {
      // Use communityId as recipientId - same approach as encryption
      return await _encryptionService.decrypt(encrypted, 'group_$communityId');
    } catch (e, stackTrace) {
      developer.log(
        'Error decrypting group message: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  
  // ========================================================================
  // PRIVATE METHODS - STORAGE
  // ========================================================================
  
  /// Generate chat ID from community ID
  String _generateChatId(String communityId) {
    return '$_chatIdPrefix$communityId';
  }
  
  /// Save message to storage
  Future<void> _saveMessage(CommunityChatMessage message) async {
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

