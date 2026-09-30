class UserEntity {
  final String roleId;
  final String roleName;
  final dynamic appsId;
  final String permissionToken;
  final String accessToken;
  final String refreshToken;

  UserEntity({
    required this.roleId,
    required this.roleName,
    required this.appsId,
    required this.permissionToken,
    required this.accessToken,
    required this.refreshToken,
  });
}
