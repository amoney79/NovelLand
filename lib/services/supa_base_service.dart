import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/novel.dart';

class SupabaseService {
  static SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // CREATE: Upload novel cover image & document file to Storage, then insert into PostgreSQL
  static Future<bool> uploadNovel({
    required String title,
    required String author,
    required String genre,
    required String synopsis,
    File? imageFile,
    File? docFile,
    List<Chapter>? chapters,
  }) async {
    final client = _client;
    if (client == null) return false;
    try {
      String imageUrl = 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500';
      String? docUrl;

      // 1. Cover Image Storage
      if (imageFile != null) {
        final imageExt = imageFile.path.split('.').last;
        final imageFileName = '${DateTime.now().millisecondsSinceEpoch}_cover.$imageExt';
        try {
          await client.storage.from('covers').upload(
            imageFileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
          imageUrl = client.storage.from('covers').getPublicUrl(imageFileName);
        } catch (storageError) {
          debugPrint('⚠️ Storage upload cover warning: $storageError');
        }
      }

      // 2. Manuscript Document Storage
      if (docFile != null) {
        final docExt = docFile.path.split('.').last;
        final docFileName = '${DateTime.now().millisecondsSinceEpoch}_doc.$docExt';
        try {
          await client.storage.from('manuscripts').upload(
            docFileName,
            docFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
          docUrl = client.storage.from('manuscripts').getPublicUrl(docFileName);
        } catch (storageError) {
          debugPrint('⚠️ Storage upload doc warning: $storageError');
        }
      }

      final chapterList = chapters != null && chapters.isNotEmpty
          ? chapters.map((c) => c.toMap()).toList()
          : [
        {
          'number': 1,
          'title': 'Chapter 1: Beginning',
          'content': synopsis,
        }
      ];

      final Map<String, dynamic> insertData = {
        'title': title,
        'author': author,
        'genre': genre,
        'image_url': imageUrl,
        'synopsis': synopsis,
        'views': '0',
        'chapters': chapterList,
      };

      if (docUrl != null) insertData['doc_url'] = docUrl;

      await client.from('novels').insert(insertData);
      return true;
    } catch (e) {
      debugPrint('❌ Supabase uploadNovel Error: $e');
      return false;
    }
  }

  // READ: Fetch all novels
  static Future<List<Novel>> fetchNovels() async {
    final client = _client;
    if (client == null) return [];
    try {
      final dynamic response = await client.from('novels').select().order('created_at', ascending: false);
      if (response is List) {
        return response.map((json) => Novel.fromMap(Map<String, dynamic>.from(json as Map))).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Supabase fetchNovels Error: $e');
      return [];
    }
  }

  // UPDATE: Edit novel in Supabase PostgreSQL
  static Future<bool> updateNovel({
    required String id,
    required String title,
    required String author,
    required String genre,
    required String synopsis,
    File? newImageFile,
    List<Chapter>? chapters,
  }) async {
    final client = _client;
    if (client == null) return false;
    try {
      final Map<String, dynamic> updateData = {
        'title': title,
        'author': author,
        'genre': genre,
        'synopsis': synopsis,
      };

      if (newImageFile != null) {
        final imageExt = newImageFile.path.split('.').last;
        final imageFileName = '${DateTime.now().millisecondsSinceEpoch}_cover.$imageExt';
        try {
          await client.storage.from('covers').upload(
            imageFileName,
            newImageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
          updateData['image_url'] = client.storage.from('covers').getPublicUrl(imageFileName);
        } catch (_) {}
      }

      if (chapters != null && chapters.isNotEmpty) {
        updateData['chapters'] = chapters.map((c) => c.toMap()).toList();
      }

      await client.from('novels').update(updateData).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('❌ Supabase updateNovel Error: $e');
      return false;
    }
  }

  // DELETE: Delete novel from Supabase PostgreSQL
  static Future<bool> deleteNovel(String id) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('novels').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('❌ Supabase deleteNovel Error: $e');
      return false;
    }
  }
}
