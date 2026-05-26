import 'package:flutter_pos/core/common/result.dart';
import 'package:flutter_pos/data/datasources/remote/auth_remote_datasource_impl.dart';
import 'package:flutter_pos/data/models/user_model.dart';
import 'package:flutter_pos/data/repositories/auth_repository_impl.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repository_impl_test.mocks.dart';

// Generate mocks with: flutter pub run build_runner build
@GenerateMocks([AuthRemoteDataSourceImpl, UserModel, UserEntity])
void main() {
  late MockAuthRemoteDataSourceImpl mockRemoteDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSourceImpl();
    repository = AuthRepositoryImpl(authRemoteDataSource: mockRemoteDataSource);

    provideDummy<Result<UserModel>>(Result.success(data: UserModel(id: '')));
    provideDummy<Result<UserModel?>>(Result.success(data: null));
    provideDummy<Result<void>>(Result.success(data: null));
  });

  group('AuthRepositoryImpl - signInWithEmailAndPassword', () {
    test('should return UserEntity on successful sign in', () async {
      // Arrange
      final mockUserModel = MockUserModel();
      final mockUserEntity = MockUserEntity();

      when(mockUserModel.toEntity()).thenReturn(mockUserEntity);
      when(mockRemoteDataSource.signInWithEmailAndPassword(
        'subdomain',
        'test@example.com',
        'password123',
      )).thenAnswer((_) async => Result.success(data: mockUserModel));

      // Act
      final result = await repository.signInWithEmailAndPassword(
        'subdomain',
        'test@example.com',
        'password123',
      );

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, mockUserEntity);
      verify(mockRemoteDataSource.signInWithEmailAndPassword(
        'subdomain',
        'test@example.com',
        'password123',
      )).called(1);
      verify(mockUserModel.toEntity()).called(1);
    });

    test('should return failure when remote datasource fails', () async {
      // Arrange
      final error = Exception('Sign in failed');
      when(mockRemoteDataSource.signInWithEmailAndPassword(
        'subdomain',
        'test@example.com',
        'password123',
      )).thenAnswer((_) async => Result.failure(error: error));

      // Act
      final result = await repository.signInWithEmailAndPassword(
        'subdomain',
        'test@example.com',
        'password123',
      );

      // Assert
      expect(result.isFailure, true);
      expect(result.error, error);
      verify(mockRemoteDataSource.signInWithEmailAndPassword(
        'subdomain',
        'test@example.com',
        'password123',
      )).called(1);
    });

    test('should catch and return exception as failure', () async {
      // Arrange
      final exception = Exception('Network error');
      when(mockRemoteDataSource.signInWithEmailAndPassword(
        'subdomain',
        'test@example.com',
        'password123',
      )).thenThrow(exception);

      // Act
      final result = await repository.signInWithEmailAndPassword(
        'subdomain',
        'test@example.com',
        'password123',
      );

      // Assert
      expect(result.isFailure, true);
      expect(result.error, exception);
      verify(mockRemoteDataSource.signInWithEmailAndPassword(
        'subdomain',
        'test@example.com',
        'password123',
      )).called(1);
    });
  });

  group('AuthRepositoryImpl - signOut', () {
    test('should return success on successful sign out', () async {
      // Arrange
      when(mockRemoteDataSource.signOut()).thenAnswer((_) async => Result.success(data: null));

      // Act
      final result = await repository.signOut();

      // Assert
      expect(result.isSuccess, true);
      verify(mockRemoteDataSource.signOut()).called(1);
    });

    test('should return failure when remote datasource fails', () async {
      // Arrange
      final error = Exception('Sign out failed');
      when(mockRemoteDataSource.signOut()).thenAnswer((_) async => Result.failure(error: error));

      // Act
      final result = await repository.signOut();

      // Assert
      expect(result.isFailure, true);
      expect(result.error, error);
      verify(mockRemoteDataSource.signOut()).called(1);
    });
  });

  group('AuthRepositoryImpl - getCurrentUser', () {
    test('should return UserEntity when user is logged in', () async {
      // Arrange
      final mockUserModel = MockUserModel();
      final mockUserEntity = MockUserEntity();

      when(mockUserModel.toEntity()).thenReturn(mockUserEntity);
      when(mockRemoteDataSource.getCurrentUser()).thenAnswer((_) async => Result.success(data: mockUserModel));

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, mockUserEntity);
      verify(mockRemoteDataSource.getCurrentUser()).called(1);
      verify(mockUserModel.toEntity()).called(1);
    });

    test('should return null when no user is logged in', () async {
      // Arrange
      when(mockRemoteDataSource.getCurrentUser()).thenAnswer((_) async => Result.success(data: null));

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, null);
      verify(mockRemoteDataSource.getCurrentUser()).called(1);
    });
  });
}
