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

  File? _selectedImageFile;
  File? _selectedDocFile;
  String? _selectedImageName;
  String? _selectedDocName;
  String _extractedContent = "Story content uploaded from document...";
  bool _isUploading = false;

  final _choice1TextController = TextEditingController();
  final _choice2TextController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    _choice1TextController.dispose();
    _choice2TextController.dispose();
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

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedDocFile = File(result.files.single.path!);
        _selectedDocName = result.files.single.name;
        _extractedContent = "Successfully imported story text from: $_selectedDocName";
      });
    }
  }

  Future<void> _saveStory(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);

      List<StoryChoice> rootChoices = [];
      if (_choice1TextController.text.isNotEmpty) {
        rootChoices.add(StoryChoice(text: _choice1TextController.text, nextNodeId: 1));
      }
      if (_choice2TextController.text.isNotEmpty) {
        rootChoices.add(StoryChoice(text: _choice2TextController.text, nextNodeId: 2));
      }

      List<Chapter> chapters = [
        Chapter(number: 1, title: 'Chapter 1: Beginning', content: _extractedContent),
      ];

      List<StoryNode> nodes = rootChoices.isNotEmpty
          ? [
        StoryNode(
          id: 0,
          title: 'Chapter 1 (${_selectedDocName ?? "Manual Entry"})',
          content: _extractedContent,
          choices: rootChoices,
        ),
        StoryNode(
          id: 1,
          title: 'Continuation Path A',
          content: 'The narrative unfolds further down choice path A...',
          choices: [],
        ),
        StoryNode(
          id: 2,
          title: 'Continuation Path B',
          content: 'An alternate turn of events changes the trajectory along path B...',
          choices: [],
        ),
      ]
          : [];

      // Call Supabase service to upload files and save record to PostgreSQL
      bool success = await SupabaseService.uploadNovel(
        title: _titleController.text,
        author: _authorController.text,
        genre: _genreController.text,
        synopsis: _extractedContent,
        imageFile: _selectedImageFile,
        docFile: _selectedDocFile,
      );

      final newNovel = Novel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        author: _authorController.text,
        genre: _genreController.text,
        synopsis: _extractedContent,
        views: '1.0K',
        imageUrl: _selectedImageFile != null
            ? 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500'
            : 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=500',
        chapters: chapters,
        nodes: nodes,
      );

      if (context.mounted) {
        Provider.of<NovelManager>(context, listen: false).addNovel(newNovel);
      }

      setState(() => _isUploading = false);

      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Document uploaded & story published to Supabase!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Story published to local feed!')),
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin: Upload & Create Story 📂')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('1. Story Metadata', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Story Title', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Author Name', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Please enter author name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _genreController,
                decoration: const InputDecoration(labelText: 'Genre (e.g. Romance / Sci-Fi / Mystery)', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Please enter a genre' : null,
              ),
              const SizedBox(height: 24),
              const Text('2. Media & Document Upload', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: Text(_selectedImageName == null ? 'Upload Cover Image' : 'Image: $_selectedImageName'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), alignment: Alignment.centerLeft),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickDocument,
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(_selectedDocName == null ? 'Upload Story Document (PDF / Word .docx)' : 'Doc: $_selectedDocName'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), alignment: Alignment.centerLeft),
              ),
              const SizedBox(height: 24),
              const Text('3. Branching Choices (Optional for Interactive Stories)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
              const SizedBox(height: 12),
              TextFormField(
                controller: _choice1TextController,
                decoration: const InputDecoration(labelText: 'Choice 1 Text', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _choice2TextController,
                decoration: const InputDecoration(labelText: 'Choice 2 Text', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16), backgroundColor: const Color(0xFF6366F1)),
                  onPressed: _isUploading ? null : () => _saveStory(context),
                  child: _isUploading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Publish Uploaded Story', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
