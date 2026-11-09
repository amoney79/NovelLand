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

  // Fetch all novels from PostgreSQL database
  static Future<List<Novel>> fetchNovels() async {
    final client = _client;
    if (client == null) {
      debugPrint('⚠️ Supabase client is null. Ensure Supabase.initialize is completed.');
      return [];
    }
    try {
      final dynamic response = await client.from('novels').select().order('created_at', ascending: false);
      debugPrint('📦 Supabase fetchNovels Response: $response');
      if (response is List) {
        final novels = response.map((json) {
          final map = Map<String, dynamic>.from(json as Map);
          return Novel.fromMap(map);
        }).toList();
        debugPrint('✅ Successfully parsed ${novels.length} novels from Supabase.');
        return novels;
      }
      return [];
    } catch (e, stack) {
      debugPrint('❌ Supabase fetchNovels Error: $e');
      debugPrint('Stacktrace: $stack');
      return [];
    }
  }

  // Upload novel cover image & document file to Supabase Storage, then save record to PostgreSQL
  static Future<bool> uploadNovel({
    required String title,
    required String author,
    required String genre,
    required String synopsis,
    File? imageFile,
    File? docFile,
  }) async {
    final client = _client;
    if (client == null) {
      debugPrint('⚠️ Supabase client is null during upload.');
      return false;
    }
    try {
      String imageUrl = 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500';
      String? docUrl;

      // 1. Upload Cover Image to Supabase Storage Bucket ('covers')
      if (imageFile != null) {
        final imageExtension = imageFile.path.split('.').last;
        final imageFileName = '${DateTime.now().millisecondsSinceEpoch}_cover.$imageExtension';
        try {
          await client.storage.from('covers').upload(
            imageFileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
          imageUrl = client.storage.from('covers').getPublicUrl(imageFileName);
          debugPrint('📸 Cover Image uploaded to Supabase Storage: $imageUrl');
        } catch (storageError) {
          debugPrint('⚠️ Cover Image storage upload warning: $storageError');
        }
      }

      // 2. Upload Manuscript Document to Supabase Storage Bucket ('manuscripts')
      if (docFile != null) {
        final docExtension = docFile.path.split('.').last;
        final docFileName = '${DateTime.now().millisecondsSinceEpoch}_doc.$docExtension';
        try {
          await client.storage.from('manuscripts').upload(
            docFileName,
            docFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
          docUrl = client.storage.from('manuscripts').getPublicUrl(docFileName);
          debugPrint('📄 Manuscript uploaded to Supabase Storage: $docUrl');
        } catch (storageError) {
          debugPrint('⚠️ Manuscript storage upload warning: $storageError');
        }
      }

      // 3. Insert Novel Record into PostgreSQL Table ('novels')
      final Map<String, dynamic> insertData = {
        'title': title,
        'author': author,
        'genre': genre,
        'image_url': imageUrl,
        'synopsis': synopsis,
        'views': '0',
        'chapters': [
          {
            'number': 1,
            'title': 'Chapter 1: The Beginning',
            'content': synopsis,
          }
        ],
      };

      if (docUrl != null) {
        insertData['doc_url'] = docUrl;
      }

      final response = await client.from('novels').insert(insertData).select();
      debugPrint('✅ Inserted novel into Supabase PostgreSQL: $response');

      return true;
    } catch (e, stack) {
      debugPrint('❌ Error uploading novel to Supabase: $e');
      debugPrint('Stacktrace: $stack');
      return false;
    }
  }
}
