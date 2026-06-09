import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';
import '../screens/community/model/event_model.dart';
import '../screens/community/model/partner_model.dart';

class CommunityService {
  static const _kPosts    = 'community_posts';
  static const _kEvents   = 'community_events';
  static const _kPartners = 'community_partners';
  static const _kLiked    = 'community_liked_posts';
  static const _kJoined   = 'community_joined_events';
  static const _kCmtPrefix = 'community_comments_';

  // ── Posts ──────────────────────────────────────────────────────────────────

  static Future<List<PostModel>> loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPosts);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> savePosts(List<PostModel> posts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPosts, jsonEncode(posts.map((p) => p.toJson()).toList()));
  }

  static Future<Set<String>> loadLikedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_kLiked) ?? []).toSet();
  }

  static Future<void> saveLikedPosts(Set<String> liked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kLiked, liked.toList());
  }

  static Future<List<String>> loadComments(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('$_kCmtPrefix$postId') ?? [];
  }

  static Future<void> addComment(String postId, String text) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kCmtPrefix$postId';
    final list = prefs.getStringList(key) ?? [];
    list.add(text);
    await prefs.setStringList(key, list);
  }

  // ── Events ─────────────────────────────────────────────────────────────────

  static Future<List<EventModel>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kEvents);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveEvents(List<EventModel> events) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEvents, jsonEncode(events.map((e) => e.toJson()).toList()));
  }

  static Future<Set<String>> loadJoinedEvents() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_kJoined) ?? []).toSet();
  }

  static Future<void> saveJoinedEvents(Set<String> joined) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kJoined, joined.toList());
  }

  // ── Partners ───────────────────────────────────────────────────────────────

  static Future<List<PartnerModel>> loadPartners() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPartners);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => PartnerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> savePartners(List<PartnerModel> partners) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kPartners, jsonEncode(partners.map((p) => p.toJson()).toList()));
  }
}
