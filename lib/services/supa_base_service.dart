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
    if (client == null) return [];
    try {
      final List<dynamic> response = await client.from('novels').select().order('created_at', ascending: false);
      return response.map((json) => Novel.fromMap(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      debugPrint('Error fetching novels from Supabase: $e');
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
    if (client == null) return false;
    try {
      String imageUrl = 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500';

      // 1. Upload Cover Image to Supabase Storage Bucket ('covers')
      if (imageFile != null) {
        final imageFileName = '${DateTime.now().millisecondsSinceEpoch}_cover.jpg';
        await client.storage.from('covers').upload(imageFileName, imageFile);
        imageUrl = client.storage.from('covers').getPublicUrl(imageFileName);
      }

      // 2. Upload Manuscript Document to Supabase Storage Bucket ('manuscripts')
      if (docFile != null) {
        final docFileName = '${DateTime.now().millisecondsSinceEpoch}_doc.pdf';
        await client.storage.from('manuscripts').upload(docFileName, docFile);
      }

      // 3. Insert Novel Record into PostgreSQL Table ('novels')
      await client.from('novels').insert({
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
            'content': synopsis
          }
        ]
      });

      return true;
    } catch (e) {
      debugPrint('Error uploading novel to Supabase: $e');
      return false;
    }
  }
}
