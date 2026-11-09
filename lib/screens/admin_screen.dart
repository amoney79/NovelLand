import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/novel.dart';
import '../services/supa_base_service.dart';

class AdminStoryCreatorScreen extends StatefulWidget {
  const AdminStoryCreatorScreen({super.key});

  @override
  State<AdminStoryCreatorScreen> createState() => _AdminStoryCreatorScreenState();
}

class _AdminStoryCreatorScreenState extends State<AdminStoryCreatorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _genreController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _chapterTitleController = TextEditingController();
  final _contentController = TextEditingController();

  File? _selectedImageFile;
  String? _selectedImageName;
  bool _isUploading = false;
  bool _isAddingNewChapterOnly = false; // Toggle between New Novel vs Chapter 2+
  int _chapterNumber = 2;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    _synopsisController.dispose();
    _chapterTitleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImageFile = File(result.files.single.path!);
        _selectedImageName = result.files.single.name;
      });
    }
  }

  Future<void> _saveStory(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);

      final synopsisText = _synopsisController.text.trim();
      final contentText = _contentController.text.trim();
      final chapterTitle = _chapterTitleController.text.trim().isNotEmpty
          ? _chapterTitleController.text.trim()
          : 'Chapter $_chapterNumber';

      List<Chapter> chapters = [
        Chapter(
          number: _isAddingNewChapterOnly ? _chapterNumber : 1,
          title: chapterTitle,
          content: contentText,
        ),
      ];

      bool success = await SupabaseService.uploadNovel(
        title: _titleController.text,
        author: _authorController.text,
        genre: _genreController.text,
        synopsis: synopsisText.isNotEmpty ? synopsisText : 'Chapter update',
        imageFile: _selectedImageFile,
        docFile: null,
      );

      final newNovel = Novel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        author: _authorController.text,
        genre: _genreController.text,
        synopsis: synopsisText,
        views: '1.0K',
        imageUrl: _selectedImageFile != null
            ? 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500'
            : 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=500',
        chapters: chapters,
        nodes: [],
      );

      if (context.mounted) {
        Provider.of<NovelManager>(context, listen: false).addNovel(newNovel);
      }

      setState(() => _isUploading = false);

      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isAddingNewChapterOnly
                ? '🎉 Chapter $_chapterNumber published to Supabase!'
                : '🎉 Linear novel published to Supabase!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Published locally!')),
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isAddingNewChapterOnly ? 'Admin: Add Chapter 2+ 📖' : 'Admin: Create Linear Novel 📖'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 0. Mode Selector Toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Creation Mode:',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                      ),
                      DropdownButton<bool>(
                        value: _isAddingNewChapterOnly,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: false, child: Text('New Novel (Chapter 1)')),
                          DropdownMenuItem(value: true, child: Text('Add Chapter (2+)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _isAddingNewChapterOnly = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 1. Metadata
                const Text('1. Story Identifier', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Novel Title', border: OutlineInputBorder()),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _authorController,
                  decoration: const InputDecoration(labelText: 'Author Name', border: OutlineInputBorder()),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter author name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _genreController,
                  decoration: const InputDecoration(labelText: 'Genre (e.g. Fantasy / Drama / Sci-Fi)', border: OutlineInputBorder()),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter a genre' : null,
                ),

                // Hide Synopsis & Cover Image if only appending Chapter 2+
                if (!_isAddingNewChapterOnly) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _synopsisController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Synopsis / Summary',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                      hintText: 'Enter a short description or teaser for the novel...',
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter a synopsis' : null,
                  ),
                  const SizedBox(height: 24),
                  const Text('2. Cover Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: Text(_selectedImageName == null ? 'Upload Cover Image' : 'Image: $_selectedImageName'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), alignment: Alignment.centerLeft),
                  ),
                ],

                const SizedBox(height: 24),
                Text(
                  _isAddingNewChapterOnly ? '2. Chapter Content' : '3. Story Content',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                ),
                const SizedBox(height: 12),

                if (_isAddingNewChapterOnly) ...[
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          initialValue: '$_chapterNumber',
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Ch. No.', border: OutlineInputBorder()),
                          onChanged: (val) => _chapterNumber = int.tryParse(val) ?? 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _chapterTitleController,
                          decoration: const InputDecoration(labelText: 'Chapter Title (Optional)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                TextFormField(
                  controller: _contentController,
                  maxLines: 12,
                  decoration: InputDecoration(
                    labelText: _isAddingNewChapterOnly ? 'Chapter Content Text' : 'Story Content / Chapter 1 Text',
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                    hintText: 'Type or paste your story text and paragraphs here...',
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter story content' : null,
                ),

                // Spacing to keep button clearly visible above mobile navigation overlays
                const SizedBox(height: 28),

                // Styled Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: const Color(0xFF6366F1),
                    ),
                    onPressed: _isUploading ? null : () => _saveStory(context),
                    child: _isUploading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                      _isAddingNewChapterOnly ? 'Publish Chapter $_chapterNumber' : 'Publish Linear Novel',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),

                // Bottom padding safety buffer so lower navigation doesn't shade the button
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}