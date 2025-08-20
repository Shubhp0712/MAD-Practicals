import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Note Model
class Note {
  String id;
  String title;
  String content;
  DateTime createdAt;
  DateTime updatedAt;
  bool isPinned;
  List<String> tags;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      // Removed color from serialization
      'isPinned': isPinned,
      'tags': tags,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      // Removed color from deserialization
      isPinned: json['isPinned'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}

// User Preferences Model
class UserPreferences {
  bool isDarkMode;
  bool rememberMe;
  String userName;
  String lastLoginDate;

  UserPreferences({
    this.isDarkMode = false,
    this.rememberMe = false,
    this.userName = '',
    this.lastLoginDate = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'rememberMe': rememberMe,
      'userName': userName,
      'lastLoginDate': lastLoginDate,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      isDarkMode: json['isDarkMode'] ?? false,
      rememberMe: json['rememberMe'] ?? false,
      userName: json['userName'] ?? '',
      lastLoginDate: json['lastLoginDate'] ?? '',
    );
  }
}

// Main Notes App
class NotesApp extends StatefulWidget {
  const NotesApp({Key? key}) : super(key: key);

  @override
  State<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> with TickerProviderStateMixin {
  List<Note> notes = [];
  List<Note> filteredNotes = [];
  UserPreferences userPrefs = UserPreferences();
  TextEditingController searchController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool isLoading = true;
  bool showWelcome = true;
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserPreferences();
    searchController.addListener(_filterNotes);
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    searchController.dispose();
    nameController.dispose();
    super.dispose();
  }

  // Load user preferences and notes
  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load user preferences
      final userPrefsJson = prefs.getString('userPreferences');
      if (userPrefsJson != null) {
        userPrefs = UserPreferences.fromJson(json.decode(userPrefsJson));
        nameController.text = userPrefs.userName;

        if (userPrefs.rememberMe && userPrefs.userName.isNotEmpty) {
          showWelcome = false;
        }
      }

      // Load notes
      await _loadNotes();

      setState(() {
        isLoading = false;
      });

      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      print('Error loading preferences: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Save user preferences
  Future<void> _saveUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userPreferences', json.encode(userPrefs.toJson()));
    } catch (e) {
      print('Error saving preferences: $e');
    }
  }

  // Load notes
  Future<void> _loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getStringList('enhanced_notes') ?? [];

      notes = notesJson
          .map((noteStr) {
            try {
              return Note.fromJson(json.decode(noteStr));
            } catch (e) {
              print('Error parsing note: $e');
              return null;
            }
          })
          .where((note) => note != null)
          .cast<Note>()
          .toList();

      notes.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });

      _filterNotes();
    } catch (e) {
      print('Error loading notes: $e');
    }
  }

  // Save notes
  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = notes
          .map((note) => json.encode(note.toJson()))
          .toList();
      await prefs.setStringList('enhanced_notes', notesJson);
    } catch (e) {
      print('Error saving notes: $e');
    }
  }

  // Filter notes
  void _filterNotes() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredNotes = notes.where((note) {
        final matchesSearch =
            query.isEmpty ||
            note.title.toLowerCase().contains(query) ||
            note.content.toLowerCase().contains(query) ||
            note.tags.any((tag) => tag.toLowerCase().contains(query));

        final matchesFilter =
            selectedFilter == 'All' ||
            (selectedFilter == 'Pinned' && note.isPinned) ||
            (selectedFilter == 'Recent' &&
                DateTime.now().difference(note.updatedAt).inDays < 7);

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  // Toggle dark mode
  void _toggleDarkMode() {
    setState(() {
      userPrefs.isDarkMode = !userPrefs.isDarkMode;
    });
    _saveUserPreferences();
  }

  // Set user name and remember me
  void _setUserPreferences() {
    if (nameController.text.trim().isEmpty) {
      _showSnackBar('Please enter your name', Colors.red);
      return;
    }

    setState(() {
      userPrefs.userName = nameController.text.trim();
      userPrefs.lastLoginDate = DateTime.now().toIso8601String();
      showWelcome = false;
    });
    _saveUserPreferences();
  }

  // Add new note
  void _addNote() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddEditNotePage(
              onSave: (title, content, tags) async {
                final newNote = Note(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  content: content,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  tags: tags,
                );

                setState(() {
                  notes.insert(0, newNote);
                });

                await _saveNotes();
                _filterNotes();
                _showSnackBar('Note created successfully!', Colors.green);
              },
              isDarkMode: userPrefs.isDarkMode,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  // Edit note
  void _editNote(Note note) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddEditNotePage(
              note: note,
              onSave: (title, content, tags) async {
                setState(() {
                  note.title = title;
                  note.content = content;
                  note.tags = tags;
                  note.updatedAt = DateTime.now();

                  notes.remove(note);
                  notes.insert(0, note);
                });

                await _saveNotes();
                _filterNotes();
                _showSnackBar('Note updated successfully!', Colors.green);
              },
              isDarkMode: userPrefs.isDarkMode,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  // Toggle pin status
  void _togglePin(Note note) {
    setState(() {
      note.isPinned = !note.isPinned;
      note.updatedAt = DateTime.now();
    });
    _saveNotes();
    _filterNotes();
    _showSnackBar(note.isPinned ? 'Note pinned' : 'Note unpinned', Colors.blue);
  }

  // Delete note
  void _deleteNote(Note note) {
    setState(() {
      notes.remove(note);
    });
    _saveNotes();
    _filterNotes();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note deleted'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              notes.insert(0, note);
            });
            _saveNotes();
            _filterNotes();
          },
        ),
      ),
    );
  }

  // Show snackbar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = userPrefs.isDarkMode ? ThemeData.dark() : ThemeData.light();

    return Theme(
      data: theme.copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      child: Scaffold(
        backgroundColor: userPrefs.isDarkMode
            ? Colors.grey[900]
            : Colors.grey[50],
        body: isLoading
            ? _buildLoadingScreen()
            : showWelcome
            ? _buildWelcomeScreen()
            : _buildMainScreen(),
        floatingActionButton: !showWelcome && !isLoading
            ? FloatingActionButton.extended(
                onPressed: _addNote,
                backgroundColor: userPrefs.isDarkMode
                    ? Colors.blue[700]
                    : Colors.blue[600],
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text('Add Note'),
              )
            : null,
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              userPrefs.isDarkMode ? Colors.blue[300]! : Colors.blue[600]!,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading your notes...',
            style: TextStyle(
              fontSize: 16,
              color: userPrefs.isDarkMode ? Colors.white70 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: userPrefs.isDarkMode
                  ? [Colors.grey[800]!, Colors.grey[900]!]
                  : [Colors.blue[400]!, Colors.purple[400]!],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.note_alt_rounded,
                      size: 60,
                      color: userPrefs.isDarkMode
                          ? Colors.grey[800]
                          : Colors.blue[600],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Welcome Title
                  const Text(
                    'Welcome to NotesApp',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Your personal note-taking companion',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),

                  const SizedBox(height: 50),

                  // Name Input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                        prefixIcon: Icon(Icons.person),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(20),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Remember Me Checkbox
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: userPrefs.rememberMe,
                        onChanged: (value) {
                          setState(() {
                            userPrefs.rememberMe = value ?? false;
                          });
                        },
                        fillColor: MaterialStateProperty.all(Colors.white),
                        checkColor: Colors.blue[600],
                      ),
                      const Text(
                        'Remember me',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Get Started Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _setUserPreferences,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Dark Mode Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.light_mode,
                        color: userPrefs.isDarkMode
                            ? Colors.white30
                            : Colors.white,
                      ),
                      Switch(
                        value: userPrefs.isDarkMode,
                        onChanged: (value) => _toggleDarkMode(),
                        activeColor: Colors.white,
                        inactiveThumbColor: Colors.white70,
                      ),
                      Icon(
                        Icons.dark_mode,
                        color: userPrefs.isDarkMode
                            ? Colors.white
                            : Colors.white30,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainScreen() {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        _buildSearchAndFilters(),
        _buildNotesGrid(),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: userPrefs.isDarkMode
          ? Colors.grey[800]
          : Colors.blue[600],
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello ! 👋',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            Text(
              '${filteredNotes.length} ${filteredNotes.length == 1 ? 'note' : 'notes'}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: userPrefs.isDarkMode
                  ? [Colors.grey[700]!, Colors.grey[800]!]
                  : [Colors.blue[400]!, Colors.purple[400]!],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            // Focus search field
          },
        ),
        IconButton(
          icon: Icon(
            userPrefs.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: Colors.white,
          ),
          onPressed: _toggleDarkMode,
        ),
        // PopupMenuButton<String>(
        //   icon: const Icon(Icons.more_vert, color: Colors.white),
        //   onSelected: (value) {
        //     if (value == 'logout') {
        //       setState(() {
        //         userPrefs.rememberMe = false;
        //         userPrefs.userName = '';
        //         showWelcome = true;
        //         nameController.clear();
        //       });
        //       _saveUserPreferences();
        //     }
        //   },
        //   itemBuilder: (context) => [
        //     const PopupMenuItem(
        //       value: 'logout',
        //       child: Row(
        //         children: [
        //           Icon(Icons.logout),
        //           SizedBox(width: 8),
        //           Text('Sign Out'),
        //         ],
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: userPrefs.isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search notes, tags...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: userPrefs.isDarkMode
                        ? Colors.white70
                        : Colors.grey[600],
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            _filterNotes();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: TextStyle(
                  color: userPrefs.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Filter Chips
            Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Pinned'),
                const SizedBox(width: 8),
                _buildFilterChip('Recent'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = selectedFilter == filter;
    return FilterChip(
      label: Text(filter),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedFilter = filter;
        });
        _filterNotes();
      },
      backgroundColor: userPrefs.isDarkMode
          ? Colors.grey[700]
          : Colors.grey[200],
      selectedColor: userPrefs.isDarkMode ? Colors.blue[700] : Colors.blue[200],
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (userPrefs.isDarkMode ? Colors.white70 : Colors.black),
      ),
    );
  }

  Widget _buildNotesGrid() {
    if (filteredNotes.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.note_add,
                size: 80,
                color: userPrefs.isDarkMode
                    ? Colors.grey[600]
                    : Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                searchController.text.isEmpty
                    ? 'No notes yet'
                    : 'No notes found',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: userPrefs.isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                searchController.text.isEmpty
                    ? 'Tap the + button to create your first note'
                    : 'Try a different search term',
                style: TextStyle(
                  fontSize: 16,
                  color: userPrefs.isDarkMode
                      ? Colors.grey[500]
                      : Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final note = filteredNotes[index];
          return _buildNoteCard(note, index);
        }, childCount: filteredNotes.length),
      ),
    );
  }

  Widget _buildNoteCard(Note note, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutBack,
      child: GestureDetector(
        onTap: () => _editNote(note),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            note.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (note.isPinned)
                          const Icon(
                            Icons.push_pin,
                            size: 16,
                            color: Colors.black54,
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Content
                    Expanded(
                      child: Text(
                        note.content,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tags
                    if (note.tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: note.tags
                            .take(2)
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),

                    const SizedBox(height: 8),

                    // Date
                    Text(
                      _formatDate(note.updatedAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions Menu
              Positioned(
                top: 8,
                right: 8,
                child: PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.black54,
                    size: 20,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'pin':
                        _togglePin(note);
                        break;
                      case 'delete':
                        _deleteNote(note);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'pin',
                      child: Row(
                        children: [
                          Icon(
                            note.isPinned
                                ? Icons.push_pin_outlined
                                : Icons.push_pin,
                          ),
                          const SizedBox(width: 8),
                          Text(note.isPinned ? 'Unpin' : 'Pin'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Add/Edit Note Page
class AddEditNotePage extends StatefulWidget {
  final Note? note;
  final Function(String title, String content, List<String> tags) onSave;
  final bool isDarkMode;

  const AddEditNotePage({
    Key? key,
    this.note,
    required this.onSave,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  late TextEditingController tagController;
  List<String> tags = [];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?.title ?? '');
    contentController = TextEditingController(text: widget.note?.content ?? '');
    tagController = TextEditingController();
    tags = List.from(widget.note?.tags ?? []);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = tagController.text.trim();
    if (tag.isNotEmpty && !tags.contains(tag)) {
      setState(() {
        tags.add(tag);
        tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      tags.remove(tag);
    });
  }

  void _saveNote() {
    final title = titleController.text.trim().isEmpty
        ? 'Untitled'
        : titleController.text.trim();

    widget.onSave(title, contentController.text.trim(), tags);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        backgroundColor: widget.isDarkMode
            ? Colors.grey[800]
            : Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveNote),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Note title...',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  hintText: 'Start writing your note...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16),
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: tagController,
                    decoration: InputDecoration(
                      hintText: 'Add a tag...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                IconButton(onPressed: _addTag, icon: const Icon(Icons.add)),
              ],
            ),
            const SizedBox(height: 8),
            if (tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags
                    .map(
                      (tag) => Chip(
                        label: Text('#$tag'),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeTag(tag),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveNote,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.save),
        label: const Text('Save Note'),
      ),
    );
  }
}
