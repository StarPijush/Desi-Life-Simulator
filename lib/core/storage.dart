// lib/core/storage.dart
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/character.dart';
import '../models/relationship.dart';

class StorageService {
  static const String _characterBoxName = 'desilife_character';
  static const String _backupBoxName = 'desilife_character_backup';
  static const String _characterKey = 'active_character';
  static const String _eventsBoxName = 'desilife_events';
  static const String _eventsKey = 'event_log';
  static const String _legacyBoxName = 'desilife_legacy';
  static const String _legacyKey = 'legacy_points';

  static Box<Character>? _characterBox;
  static Box<Character>? _backupBox;
  static Box<dynamic>? _eventsBox;
  static Box<dynamic>? _legacyBox;

  static bool _isSaving = false;
  static bool _pendingSave = false;
  static Character? _pendingCharacter;
  static final List<Completer<void>> _saveWaiters = [];

  /// Initialize Hive and open boxes
  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CharacterAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(RelationshipAdapter());
    }
    // Note: LegacyStoreAdapter will need to be generated
    // For now we can use dynamic or register when ready

    _characterBox = await Hive.openBox<Character>(_characterBoxName);
    _backupBox = await Hive.openBox<Character>(_backupBoxName);
    _eventsBox = await Hive.openBox(_eventsBoxName);
    _legacyBox = await Hive.openBox(_legacyBoxName);
  }

  /// Checks if any valid save data exists at all
  static bool hasSavedCharacter() {
    return (_characterBox?.containsKey(_characterKey) ?? false) || 
           (_backupBox?.containsKey(_characterKey) ?? false);
  }

  /// Save (or update) the active character with queue logic and timestamp priority
  /// Returns a Future that completes when the CURRENT character state (or a newer one)
  /// has been successfully persisted to disk.
  static Future<void> saveCharacter(Character character) async {
    final completer = Completer<void>();
    _saveWaiters.add(completer);

    if (_isSaving) {
      _pendingCharacter = character;
      _pendingSave = true;
      return completer.future;
    }

    _isSaving = true;
    Character characterToSave = character;
    
    // Ensure version is incremented if not already done by caller
    // This provides a safety net for implicit mutations
    characterToSave.stateVersion++;

    try {
      bool keepSaving = true;
      while (keepSaving) {
        _pendingSave = false;
        
        // Update freshness timestamp right before write
        characterToSave.lastSavedAt = DateTime.now().millisecondsSinceEpoch;

        int attempts = 0;
        const int maxAttempts = 2;
        bool success = false;

        while (attempts < maxAttempts && !success) {
          try {
            // 1. Save to backup box first for extra safety
            final characterClone = Character.fromJson(characterToSave.toJson());
            await _backupBox?.put(_characterKey, characterClone);
            
            // 2. Save to main box
            await _characterBox?.put(_characterKey, characterToSave);
            success = true;
          } catch (e) {
            attempts++;
            print("⚠️ Save Attempt $attempts failed: $e");
          }
        }

        // Check if another save was requested during the write
        if (_pendingSave && _pendingCharacter != null) {
          characterToSave = _pendingCharacter!;
        } else {
          keepSaving = false;
        }
      }
    } finally {
      _isSaving = false;
      _pendingCharacter = null;
      
      // Atomic Release: Complete all pending waiters now that at least one
      // full save cycle (including any queued updates) has completed successfully.
      final waiters = List<Completer<void>>.from(_saveWaiters);
      _saveWaiters.clear();
      for (var waiter in waiters) {
        if (!waiter.isCompleted) waiter.complete();
      }
    }
    
    return completer.future;
  }

  /// Load the active character with smart priority and zero-crash fallback
  static Character loadCharacter() {
    Character? main;
    Character? backup;

    try {
      main = _characterBox?.get(_characterKey);
      backup = _backupBox?.get(_characterKey);

      // Aggressive repair if they exist
      if (main != null) main.repair();
      if (backup != null) backup.repair();

      // Priority Analysis: Newer timestamp wins
      if (main != null && backup != null) {
        if (!main.isUnusable() && !backup.isUnusable()) {
          return main.lastSavedAt >= backup.lastSavedAt 
              ? _handleVersionMigration(main) 
              : _handleVersionMigration(backup);
        }
      }

      // Fallback to whichever is usable
      if (main != null && !main.isUnusable()) return _handleVersionMigration(main);
      if (backup != null && !backup.isUnusable()) return _handleVersionMigration(backup);

    } catch (e) {
      print("🛡️ Loading critical failure: $e");
    }

    // Zero-Crash Rule: Never return null
    print("🛡️ All saves unusable or missing. Returning default safe character.");
    return Character.defaultCharacter();
  }

  /// Handles soft version migration without progress loss
  static Character _handleVersionMigration(Character character) {
    if (character.version != kCurrentSaveVersion) {
      print("🔄 Migrating save from v${character.version} to v$kCurrentSaveVersion");
      character.version = kCurrentSaveVersion;
      saveCharacter(character); 
    }
    return character;
  }

  /// Delete the active character (start new life)
  static Future<void> deleteCharacter() async {
    await _characterBox?.delete(_characterKey);
  }

  /// Save event log
  static Future<void> saveEvents(List<dynamic> events) async {
    // Limit stored events to last 200 to protect storage performance
    List<dynamic> limitedEvents = events;
    if (events.length > 200) {
      limitedEvents = events.sublist(events.length - 200);
    }
    await _eventsBox?.put(_eventsKey, limitedEvents);
  }

  /// Load event log
  static List<dynamic> loadEvents() {
    final raw = _eventsBox?.get(_eventsKey);
    if (raw == null) return List<dynamic>.from([]);
    return List<dynamic>.from(raw as List);
  }

  /// Legacy logic
  static int getLegacyPoints() {
    return _legacyBox?.get(_legacyKey, defaultValue: 0) ?? 0;
  }

  static Future<void> addLegacyPoints(int points) async {
    final current = getLegacyPoints();
    await _legacyBox?.put(_legacyKey, current + points);
  }

  /// Clear all data
  static Future<void> clearAll() async {
    await _characterBox?.clear();
    await _eventsBox?.clear();
  }

  /// Close boxes (call on app dispose)
  static Future<void> close() async {
    await _characterBox?.close();
    await _eventsBox?.close();
  }
}
