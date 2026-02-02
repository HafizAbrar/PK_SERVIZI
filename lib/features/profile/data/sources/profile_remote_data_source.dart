import 'package:dio/dio.dart';
import '../models/user_profile.dart';
import '../models/update_profile_dto.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfile> getProfile();
  Future<UserProfile> updateProfile(UpdateProfileDto dto);
  Future<void> deleteProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSourceImpl(this._dio);

  @override
  Future<UserProfile> getProfile() async {
    final response = await _dio.get('/api/v1/users/profile');
    return UserProfile.fromJson(response.data['data']);
  }

  @override
  Future<UserProfile> updateProfile(UpdateProfileDto dto) async {
    final response = await _dio.put('/api/v1/users/profile', data: dto.toJson());
    return UserProfile.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteProfile() async {
    await _dio.delete('/api/v1/users/profile');
  }
}