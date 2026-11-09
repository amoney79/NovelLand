import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/novel.dart';
import '../services/supa_base_service.dart';

class AdminStoryCreatorScreen extends StatefulWidget {
  final Novel? initialNovel;
  final Chapter? initialChapterToEdit;

  const AdminStoryCreatorScreen({
    super.key,
    this.initialNovel,
    this.initialChapterToEdit,
  });

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

  // Creation Mode: 0 = New Novel, 1 = Add New Chapter, 2 = Edit Existing Chapter
  int _creationMode = 0;
  int _chapterNumber = 1;
  Novel? _selectedExistingNovel;
  Chapter? _selectedExistingChapter;

  @override
  void initState() {
    super.initState();
    if (widget.initialChapterToEdit != null && widget.initialNovel != null) {
      _creationMode = 2; // Edit Chapter
      _selectedExistingNovel = widget.initialNovel;
      _selectedExistingChapter = widget.initialChapterToEdit;
      _chapterNumber = widget.initialChapterToEdit!.number;
      _chapterTitleController.text = widget.initialChapterToEdit!.title;
      _contentController.text = widget.initialChapterToEdit!.content;
    } else if (widget.initialNovel != null) {
      _creationMode = 1; // Add Chapter
      _selectedExistingNovel = widget.initialNovel;
      _chapterNumber = widget.initialNovel!.chapters.length + 1;
    }
  }

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

  void _onNovelSelected(Novel? novel) {
    setState(() {
      _selectedExistingNovel = novel;
      if (novel != null) {
        if (_creationMode == 1) { // Add Chapter
          _chapterNumber = novel.chapters.length + 1;
          _chapterTitleController.clear();
          _contentController.clear();
        } else if (_creationMode == 2 && novel.chapters.isNotEmpty) { // Edit Chapter
          _selectedExistingChapter = novel.chapters.first;
          _chapterNumber = _selectedExistingChapter!.number;
          _chapterTitleController.text = _selectedExistingChapter!.title;
          _contentController.text = _selectedExistingChapter!.content;
        }
      }
    });
  }

  void _onChapterSelected(Chapter? chapter) {
    if (chapter != null) {
      setState(() {
        _selectedExistingChapter = chapter;
        _chapterNumber = chapter.number;
        _chapterTitleController.text = chapter.title;
        _contentController.text = chapter.content;
      });
    }
  }

  Future<void> _saveStory(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    final novelManager = Provider.of<NovelManager>(context, listen: false);
    final contentText = _contentController.text.trim();
    final chapterTitle = _chapterTitleController.text.trim().isNotEmpty
        ? _chapterTitleController.text.trim()
        : 'Chapter $_chapterNumber';

    bool success = false;

    if (_creationMode == 1) {
      // ADD NEW CHAPTER to existing novel
      if (_selectedExistingNovel == null) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a novel first')));
        return;
      }

      final newChapter = Chapter(
        number: _chapterNumber,
        title: chapterTitle,
        content: contentText,
      );

      final updatedChapters = List<Chapter>.from(_selectedExistingNovel!.chapters)..add(newChapter);

      success = await SupabaseService.updateNovel(
        id: _selectedExistingNovel!.id,
        title: _selectedExistingNovel!.title,
        author: _selectedExistingNovel!.author,
        genre: _selectedExistingNovel!.genre,
        synopsis: _selectedExistingNovel!.synopsis,
        chapters: updatedChapters,
      );

      if (success) {
        novelManager.addChapterToNovel(_selectedExistingNovel!.id, newChapter);
      }
    } else if (_creationMode == 2) {
      // EDIT EXISTING CHAPTER of novel
      if (_selectedExistingNovel == null || _selectedExistingChapter == null) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a chapter to edit')));
        return;
      }

      final updatedChapter = Chapter(
        number: _selectedExistingChapter!.number,
        title: chapterTitle,
        content: contentText,
      );

      final updatedChapters = List<Chapter>.from(_selectedExistingNovel!.chapters);
      final index = updatedChapters.indexWhere((c) => c.number == _selectedExistingChapter!.number);
      if (index != -1) {
        updatedChapters[index] = updatedChapter;
      } else {
        updatedChapters.add(updatedChapter);
      }

      success = await SupabaseService.updateNovel(
        id: _selectedExistingNovel!.id,
        title: _selectedExistingNovel!.title,
        author: _selectedExistingNovel!.author,
        genre: _selectedExistingNovel!.genre,
        synopsis: _selectedExistingNovel!.synopsis,
        chapters: updatedChapters,
      );

      if (success) {
        novelManager.updateChapterInNovel(
          _selectedExistingNovel!.id,
          _selectedExistingChapter!.number,
          updatedChapter,
        );
      }
    } else {
      // CREATE BRAND NEW NOVEL
      final synopsisText = _synopsisController.text.trim();
      List<Chapter> chapters = [
        Chapter(
          number: 1,
          title: chapterTitle.isNotEmpty ? chapterTitle : 'Chapter 1: The Beginning',
          content: contentText,
        ),
      ];

      success = await SupabaseService.uploadNovel(
        title: _titleController.text,
        author: _authorController.text,
        genre: _genreController.text,
        synopsis: synopsisText.isNotEmpty ? synopsisText : 'Novel summary',
        imageFile: _selectedImageFile,
        docFile: null,
        chapters: chapters,
      );
    }

    setState(() => _isUploading = false);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_creationMode == 2
              ? 'Chapter updated successfully!'
              : (_creationMode == 1 ? 'Chapter $_chapterNumber added!' : 'Novel published successfully!')),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Operation failed. Please check network/permissions.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final novelManager = Provider.of<NovelManager>(context);
    final allNovels = novelManager.novels;

    // Safely resolve the active selected novel from allNovels list
    Novel? activeNovel;
    if (_selectedExistingNovel != null) {
      try {
        activeNovel = allNovels.firstWhere(
          (n) => n.id == _selectedExistingNovel!.id || n.title.trim().toLowerCase() == _selectedExistingNovel!.title.trim().toLowerCase(),
        );
      } catch (_) {
        activeNovel = allNovels.isNotEmpty ? allNovels.first : null;
      }
    } else if (allNovels.isNotEmpty) {
      activeNovel = allNovels.first;
    }

    // Safely resolve active chapter from activeNovel's chapters
    Chapter? activeChapter;
    if (activeNovel != null && activeNovel.chapters.isNotEmpty) {
      if (_selectedExistingChapter != null) {
        try {
          activeChapter = activeNovel.chapters.firstWhere(
            (c) => c.number == _selectedExistingChapter!.number,
          );
        } catch (_) {
          activeChapter = activeNovel.chapters.first;
        }
      } else {
        activeChapter = activeNovel.chapters.first;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _creationMode == 2
              ? 'Admin: Edit Chapter'
              : (_creationMode == 1 ? 'Admin: Add New Chapter' : 'Admin: Create New Novel'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mode Selector Segmented Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('New Novel'),
                          selected: _creationMode == 0,
                          onSelected: (val) {
                            if (val) setState(() => _creationMode = 0);
                          },
                          selectedColor: const Color(0xFF6366F1),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Add Chapter'),
                          selected: _creationMode == 1,
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _creationMode = 1;
                                if (allNovels.isNotEmpty) {
                                  _onNovelSelected(allNovels.first);
                                }
                              });
                            }
                          },
                          selectedColor: const Color(0xFF6366F1),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Edit Chapter'),
                          selected: _creationMode == 2,
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _creationMode = 2;
                                if (allNovels.isNotEmpty) {
                                  _onNovelSelected(allNovels.first);
                                }
                              });
                            }
                          },
                          selectedColor: const Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // MODE 1 or 2: Novel Dropdown Selector
                if ((_creationMode == 1 || _creationMode == 2) && allNovels.isNotEmpty) ...[
                  const Text('Select Target Novel:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Novel>(
                    initialValue: activeNovel,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: allNovels.map((novel) {
                      return DropdownMenuItem<Novel>(
                        value: novel,
                        child: Text('${novel.title} (${novel.chapters.length} Ch.)', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: _onNovelSelected,
                    validator: (val) => val == null ? 'Please select a novel' : null,
                  ),
                  const SizedBox(height: 16),
                ],

                // MODE 2 ONLY: Chapter Dropdown Selector
                if (_creationMode == 2 && activeNovel != null && activeNovel.chapters.isNotEmpty) ...[
                  const Text('Select Chapter to Edit:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFEC4899))),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Chapter>(
                    initialValue: activeChapter,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: activeNovel.chapters.map((ch) {
                      return DropdownMenuItem<Chapter>(
                        value: ch,
                        child: Text('Ch. ${ch.number}: ${ch.title}', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: _onChapterSelected,
                    validator: (val) => val == null ? 'Please select a chapter to edit' : null,
                  ),
                  const SizedBox(height: 20),
                ],

                // MODE 0 ONLY: New Novel Metadata Fields
                if (_creationMode == 0) ...[
                  const Text('1. Novel Metadata', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _synopsisController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Synopsis / Teaser Summary',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter a synopsis' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('2. Cover Image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: Text(_selectedImageName == null ? 'Upload Cover Image File' : 'Selected: $_selectedImageName'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), alignment: Alignment.centerLeft),
                  ),
                  const SizedBox(height: 20),
                ],

                // Chapter Title & Content Fields
                Text(
                  _creationMode == 2
                      ? 'Edit Chapter Content:'
                      : (_creationMode == 1 ? 'New Chapter Content:' : '3. Initial Chapter Content:'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: TextFormField(
                        initialValue: '$_chapterNumber',
                        key: ValueKey('ch_num_$_chapterNumber'),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Ch. No.', border: OutlineInputBorder()),
                        onChanged: (val) => _chapterNumber = int.tryParse(val) ?? _chapterNumber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _chapterTitleController,
                        decoration: const InputDecoration(labelText: 'Chapter Title', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _contentController,
                  maxLines: 12,
                  decoration: const InputDecoration(
                    labelText: 'Chapter Content Text',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                    hintText: 'Type or paste your story text and paragraphs here...',
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter content text' : null,
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: _creationMode == 2 ? const Color(0xFFEC4899) : const Color(0xFF6366F1),
                    ),
                    onPressed: _isUploading ? null : () => _saveStory(context),
                    child: _isUploading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                      _creationMode == 2
                          ? 'Update Chapter ${activeChapter?.number ?? ""}'
                          : (_creationMode == 1 ? 'Publish Chapter $_chapterNumber' : 'Publish New Novel'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
