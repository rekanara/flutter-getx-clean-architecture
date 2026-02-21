import '../../../../domain/auth/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.roleId,
    required super.roleName,
    required super.appsId,
    required super.permissionToken,
    required super.accessToken,
    required super.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    var role = json['role'];
    return UserModel(
      roleId: role != null ? role['id']?.toString() ?? '' : '',
      roleName: role != null ? role['name']?.toString() ?? '' : '',
      appsId: json['apps_id'],
      permissionToken: json['permission_token'] ?? '',
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': {'id': roleId, 'name': roleName},
      'apps_id': appsId,
      'permission_token': permissionToken,
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }
}
