import 'package:supabase_flutter/supabase_flutter.dart';
import '../../interfaces/data_backend.dart';
import '../../models/api_response.dart';

/// Supabase data backend implementation
class SupabaseDataBackend implements DataBackend {
  final SupabaseClient _client;
  Map<String, dynamic> _config = {};
  bool _isInitialized = false;
  
  SupabaseDataBackend(this._client);
  
  @override
  bool get isInitialized => _isInitialized;
  
  @override
  Future<void> initialize(Map<String, dynamic> config) async {
    _config = Map.unmodifiable(config);
    _isInitialized = true;
  }
  
  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }
  
  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getDocuments(
    String collection,
    {Map<String, dynamic>? filters,
    String? orderBy,
    bool descending = false,
    int? limit,
    int? offset}
  ) async {
    try {
      var query = _client.from(collection).select();
      
      // Apply filters
      if (filters != null) {
        for (final entry in filters.entries) {
          query = query.eq(entry.key, entry.value);
        }
      }
      
      // Apply ordering
      if (orderBy != null) {
        query = query.order(orderBy, ascending: !descending);
      }
      
      // Apply pagination
      if (limit != null) {
        query = query.limit(limit);
      }
      
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      }
      
      final response = await query.execute();
      
      if (response.data != null) {
        final List<Map<String, dynamic>> documents = 
          (response.data as List).cast<Map<String, dynamic>>();
        return ApiResponse.success(documents);
      } else {
        return ApiResponse.error('No data returned');
      }
      
    } catch (e) {
      return ApiResponse.error('Get documents failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<Map<String, dynamic>>> getDocument(
    String collection,
    String id,
  ) async {
    try {
      final response = await _client
        .from(collection)
        .select()
        .eq('id', id)
        .single()
        .execute();
      
      if (response.data != null) {
        return ApiResponse.success(response.data as Map<String, dynamic>);
      } else {
        return ApiResponse.error('Document not found');
      }
      
    } catch (e) {
      return ApiResponse.error('Get document failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<Map<String, dynamic>>> createDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client
        .from(collection)
        .insert(data)
        .select()
        .single()
        .execute();
      
      if (response.data != null) {
        return ApiResponse.success(response.data as Map<String, dynamic>);
      } else {
        return ApiResponse.error('Create document failed: No data returned');
      }
      
    } catch (e) {
      return ApiResponse.error('Create document failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<Map<String, dynamic>>> updateDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client
        .from(collection)
        .update(data)
        .eq('id', id)
        .select()
        .single()
        .execute();
      
      if (response.data != null) {
        return ApiResponse.success(response.data as Map<String, dynamic>);
      } else {
        return ApiResponse.error('Update document failed: No data returned');
      }
      
    } catch (e) {
      return ApiResponse.error('Update document failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<void>> deleteDocument(
    String collection,
    String id,
  ) async {
    try {
      await _client
        .from(collection)
        .delete()
        .eq('id', id)
        .execute();
      
      return ApiResponse.success(null);
      
    } catch (e) {
      return ApiResponse.error('Delete document failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> searchDocuments(
    String collection,
    String query,
    {List<String>? fields,
    Map<String, dynamic>? filters}
  ) async {
    try {
      var searchQuery = _client
        .from(collection)
        .select()
        .textSearch('fts', query);
      
      // Apply additional filters
      if (filters != null) {
        for (final entry in filters.entries) {
          searchQuery = searchQuery.eq(entry.key, entry.value);
        }
      }
      
      final response = await searchQuery.execute();
      
      if (response.data != null) {
        final List<Map<String, dynamic>> documents = 
          (response.data as List).cast<Map<String, dynamic>>();
        return ApiResponse.success(documents);
      } else {
        return ApiResponse.error('Search failed: No data returned');
      }
      
    } catch (e) {
      return ApiResponse.error('Search documents failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<void>> batchWrite(
    List<BatchOperation> operations,
  ) async {
    try {
      // Supabase doesn't have native batch operations, so we'll execute sequentially
      for (final operation in operations) {
        switch (operation.type) {
          case BatchOperationType.create:
            await _client
              .from(operation.collection)
              .insert(operation.data!)
              .execute();
            break;
            
          case BatchOperationType.update:
            await _client
              .from(operation.collection)
              .update(operation.data!)
              .eq('id', operation.id!)
              .execute();
            break;
            
          case BatchOperationType.delete:
            await _client
              .from(operation.collection)
              .delete()
              .eq('id', operation.id!)
              .execute();
            break;
        }
      }
      
      return ApiResponse.success(null);
      
    } catch (e) {
      return ApiResponse.error('Batch write failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<String>> uploadFile(
    String path,
    List<int> data,
    String contentType,
  ) async {
    try {
      final response = await _client.storage
        .from('files')
        .uploadBinary(path, data, fileOptions: FileOptions(
          contentType: contentType,
        ));
      
      return ApiResponse.success(response);
      
    } catch (e) {
      return ApiResponse.error('Upload file failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<List<int>>> downloadFile(String path) async {
    try {
      final response = await _client.storage
        .from('files')
        .download(path);
      
      return ApiResponse.success(response);
      
    } catch (e) {
      return ApiResponse.error('Download file failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<String>> getFileUrl(String path) async {
    try {
      final response = await _client.storage
        .from('files')
        .getPublicUrl(path);
      
      return ApiResponse.success(response);
      
    } catch (e) {
      return ApiResponse.error('Get file URL failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<void>> deleteFile(String path) async {
    try {
      await _client.storage
        .from('files')
        .remove([path]);
      
      return ApiResponse.success(null);
      
    } catch (e) {
      return ApiResponse.error('Delete file failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<void>> runTransaction(
    Future<void> Function() transaction,
  ) async {
    try {
      // Supabase doesn't have native transactions, so we'll execute the function
      await transaction();
      return ApiResponse.success(null);
      
    } catch (e) {
      return ApiResponse.error('Transaction failed: $e');
    }
  }
}

/// Batch operation model
class BatchOperation {
  final BatchOperationType type;
  final String collection;
  final String? id;
  final Map<String, dynamic>? data;
  
  const BatchOperation({
    required this.type,
    required this.collection,
    this.id,
    this.data,
  });
}

/// Batch operation types
enum BatchOperationType {
  create,
  update,
  delete,
}
