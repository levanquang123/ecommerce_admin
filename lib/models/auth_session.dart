import 'user.dart';

class AuthSession {
  final User? user;
  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;
  final String? accessTokenExpiresIn;

  const AuthSession({
    this.user,
    this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.accessTokenExpiresIn,
  });

  bool get hasAccessToken => accessToken != null && accessToken!.isNotEmpty;
  bool get hasRefreshToken => refreshToken != null && refreshToken!.isNotEmpty;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final dynamic userJson = json['user'];
    final String? preferredAccessToken = json['accessToken']?.toString();
    final String? fallbackToken = json['token']?.toString();
    final String? resolvedAccessToken = (preferredAccessToken != null &&
            preferredAccessToken.isNotEmpty)
        ? preferredAccessToken
        : fallbackToken;

    return AuthSession(
      user: userJson is Map<String, dynamic> ? User.fromJson(userJson) : null,
      accessToken: resolvedAccessToken,
      refreshToken: json['refreshToken']?.toString(),
      tokenType: json['tokenType']?.toString(),
      accessTokenExpiresIn: json['accessTokenExpiresIn']?.toString(),
    );
  }
}
