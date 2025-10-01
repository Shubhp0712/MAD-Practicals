import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(const NotesApp());

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const NotesHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Note {
  String id, title, content;
  DateTime createdAt, updatedAt;
  bool isPinned;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isPinned': isPinned,
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    isPinned: json['isPinned'] ?? false,
  );
}

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage>
    with TickerProviderStateMixin {
  List<Note> notes = [];
  bool isDarkMode = false, isGridView = false;
  String searchQuery = '';
  late AnimationController _fabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('notes') ?? [];
    setState(() {
      notes = notesJson.map((e) => Note.fromJson(json.decode(e))).toList();
      notes.sort(
        (a, b) => a.isPinned == b.isPinned
            ? b.updatedAt.compareTo(a.updatedAt)
            : b.isPinned
            ? 1
            : -1,
      );
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      isGridView = prefs.getBool('isGridView') ?? false;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = notes.map((note) => json.encode(note.toJson())).toList();
    await Future.wait([
      prefs.setStringList('notes', notesJson),
      prefs.setBool('isDarkMode', isDarkMode),
      prefs.setBool('isGridView', isGridView),
    ]);
  }

  void _toggleTheme() => setState(() {
    isDarkMode = !isDarkMode;
    _saveData();
  });

  void _toggleView() => setState(() {
    isGridView = !isGridView;
    _saveData();
  });

  void _togglePin(Note note) => setState(() {
    note.isPinned = !note.isPinned;
    notes.sort(
      (a, b) => a.isPinned == b.isPinned
          ? b.updatedAt.compareTo(a.updatedAt)
          : b.isPinned
          ? 1
          : -1,
    );
    _saveData();
  });

  void _deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => notes.remove(note));
              _saveData();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addOrEditNote([Note? note]) async {
    final result = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (context) => NoteEditPage(note: note)),
    );

    if (result != null) {
      setState(() {
        if (note == null) {
          notes.insert(0, result);
        } else {
          final index = notes.indexOf(note);
          notes[index] = result;
        }
        notes.sort(
          (a, b) => a.isPinned == b.isPinned
              ? b.updatedAt.compareTo(a.updatedAt)
              : b.isPinned
              ? 1
              : -1,
        );
      });
      _saveData();
    }
  }

  List<Note> get filteredNotes => searchQuery.isEmpty
      ? notes
      : notes
            .where(
              (note) =>
                  note.title.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  note.content.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ),
            )
            .toList();

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayNotes = filteredNotes;

    return Theme(
      data: isDarkMode ? ThemeData.dark(useMaterial3: true) : theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Notes',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isGridView
                      ? Icons.view_list_rounded
                      : Icons.grid_view_rounded,
                  key: ValueKey(isGridView),
                ),
              ),
              onPressed: _toggleView,
            ),
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  key: ValueKey(isDarkMode),
                ),
              ),
              onPressed: _toggleTheme,
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => searchQuery = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                ),
              ),
            ),
            // Stats
            if (notes.isNotEmpty && searchQuery.isEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildStatCard(
                      'Total',
                      notes.length.toString(),
                      Icons.note_alt_rounded,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Pinned',
                      notes.where((n) => n.isPinned).length.toString(),
                      Icons.push_pin_rounded,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            // Notes
            Expanded(
              child: displayNotes.isEmpty
                  ? _buildEmptyState()
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isGridView
                          ? _buildGridView(displayNotes)
                          : _buildListView(displayNotes),
                    ),
            ),
          ],
        ),
        floatingActionButton: ScaleTransition(
          scale: CurvedAnimation(
            parent: _fabController,
            curve: Curves.elasticOut,
          ),
          child: FloatingActionButton.extended(
            onPressed: () => _addOrEditNote(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Note'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 11, color: theme.hintColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              searchQuery.isNotEmpty
                  ? Icons.search_off_rounded
                  : Icons.note_add_rounded,
              size: 64,
              color: theme.primaryColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            searchQuery.isNotEmpty ? 'No notes found' : 'No notes yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Create your first note to get started',
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
          ),
          if (searchQuery.isEmpty) ...[
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _addOrEditNote(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Note'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListView(List<Note> displayNotes) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: displayNotes.length,
      itemBuilder: (context, index) {
        final note = displayNotes[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 200 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) => Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(opacity: value, child: _buildNoteCard(note, false)),
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<Note> displayNotes) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: displayNotes.length,
      itemBuilder: (context, index) {
        final note = displayNotes[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 200 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: Opacity(opacity: value, child: _buildNoteCard(note, true)),
          ),
        );
      },
    );
  }

  Widget _buildNoteCard(Note note, bool isGrid) {
    final theme = Theme.of(context);
    return Hero(
      tag: 'note-${note.id}',
      child: Card(
        elevation: 3,
        margin: EdgeInsets.only(bottom: isGrid ? 0 : 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _addOrEditNote(note),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (note.isPinned) ...[
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.push_pin_rounded,
                          size: 14,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        note.title.isEmpty ? 'Untitled' : note.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, size: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onSelected: (value) {
                        if (value == 'pin') _togglePin(note);
                        if (value == 'delete') _deleteNote(note);
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'pin',
                          child: Row(
                            children: [
                              Icon(
                                note.isPinned
                                    ? Icons.push_pin_outlined
                                    : Icons.push_pin_rounded,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(note.isPinned ? 'Unpin' : 'Pin'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (note.content.isNotEmpty) ...[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(
                          0.1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        note.content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                        maxLines: isGrid ? 6 : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: theme.hintColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _formatDate(note.updatedAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NoteEditPage extends StatefulWidget {
  final Note? note;

  const NoteEditPage({super.key, this.note});

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  late TextEditingController _titleController, _contentController;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _titleController.addListener(_onChanged);
    _contentController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() => _hasChanges = true);

  void _save() {
    final now = DateTime.now();
    final note = Note(
      id: widget.note?.id ?? now.millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
      isPinned: widget.note?.isPinned ?? false,
    );
    Navigator.pop(context, note);
  }

  void _onBack() {
    if (_hasChanges &&
        (_titleController.text.trim().isNotEmpty ||
            _contentController.text.trim().isNotEmpty)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Save Changes?'),
          content: const Text(
            'You have unsaved changes. Do you want to save them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context)
                ..pop()
                ..pop(),
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _save();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Hero(
      tag: widget.note != null ? 'note-${widget.note!.id}' : 'new-note',
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.note == null ? 'New Note' : 'Edit Note',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: _onBack,
          ),
          actions: [
            ElevatedButton.icon(
              onPressed:
                  (_titleController.text.trim().isNotEmpty ||
                      _contentController.text.trim().isNotEmpty)
                  ? _save
                  : null,
              icon: const Icon(Icons.save_rounded, size: 16),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surface.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            children: [
              Container(height: 3, color: theme.primaryColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(
                            0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.primaryColor.withOpacity(0.2),
                          ),
                        ),
                        child: TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'Note title...',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                            prefixIcon: Icon(
                              Icons.title_rounded,
                              color: theme.primaryColor.withOpacity(0.7),
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.primaryColor.withOpacity(0.1),
                            ),
                          ),
                          child: TextField(
                            controller: _contentController,
                            decoration: const InputDecoration(
                              hintText: 'Start writing...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
