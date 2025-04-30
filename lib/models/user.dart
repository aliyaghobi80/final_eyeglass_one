import 'package:eyewear/utils/constants.dart';
import 'dart:convert';

class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool isStaff;
  final bool isActive;
  final String? profilePictureUrl;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  String accessToken;
  String refreshToken;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isStaff,
    required this.isActive,
    this.profilePictureUrl,
    this.phone,
    this.createdAt,
    this.updatedAt,
    required this.accessToken,
    required this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Extract user data from the response structure
    final userData = json['user'] as Map<String, dynamic>? ?? json;
    final profile = userData['profile'] as Map<String, dynamic>?;

    // Helper function to decode Persian text
    String decodePersianText(String? text) {
      if (text == null) return '';
      try {
        // First try to decode as UTF-8
        return utf8.decode(text.codeUnits);
      } catch (e) {
        // If UTF-8 decoding fails, try to decode as base64
        try {
          return utf8.decode(base64.decode(text));
        } catch (e) {
          // If both fail, return the original text
          return text;
        }
      }
    }

    // Helper function to get full profile picture URL
    String? getProfilePictureUrl(String? url) {
      if (url == null) return null;
      if (url.startsWith('http')) return url;
      return '${Constants.baseUrl}$url';
    }

    return User(
      id: userData['id'] ?? 0,
      username: userData['username'] ?? '',
      email: userData['email'] ?? '',
      firstName: decodePersianText(userData['first_name']),
      lastName: decodePersianText(userData['last_name']),
      isStaff: userData['is_staff'] ?? false,
      isActive: userData['is_active'] ?? true,
      profilePictureUrl: getProfilePictureUrl(profile?['profile_picture']),
      phone: profile?['phone']?.toString(),
      createdAt:
          profile?['created_at'] != null
              ? DateTime.parse(profile!['created_at'])
              : null,
      updatedAt:
          profile?['updated_at'] != null
              ? DateTime.parse(profile!['updated_at'])
              : null,
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_staff': isStaff,
      'is_active': isActive,
      'profile': {
        'profile_picture': profilePictureUrl,
        'phone': phone,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      },
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }
}
