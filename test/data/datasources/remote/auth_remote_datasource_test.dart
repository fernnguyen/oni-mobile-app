import 'package:flutter_pos/data/datasources/remote/auth_remote_datasource_impl.dart';
import 'package:flutter_pos/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_remote_datasource_test.mocks.dart';

@GenerateMocks([SupabaseClient, GoTrueClient, AuthResponse, User])
void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGotrueClient;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGotrueClient = MockGoTrueClient();
    
    // Stub supabaseClient.auth to return our mock GotrueClient
    when(mockSupabaseClient.auth).thenReturn(mockGotrueClient);
    
    dataSource = AuthRemoteDataSourceImpl(
      supabaseClient: mockSupabaseClient,
    );
  });

  group('signInWithEmailAndPassword', () {
    late MockAuthResponse mockAuthResponse;
    late MockUser mockUser;

    setUp(() {
      mockAuthResponse = MockAuthResponse();
      mockUser = MockUser();
    });

    test('successfully signs in and returns UserModel', () async {
      // Arrange
      when(mockGotrueClient.signInWithPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockAuthResponse);

      when(mockAuthResponse.user).thenReturn(mockUser);
      when(mockUser.id).thenReturn('test_uid');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.phone).thenReturn('123456');
      when(mockUser.userMetadata).thenReturn({
        'name': 'Test User',
        'avatar_url': 'https://example.com/avatar.png',
      });
      when(mockUser.createdAt).thenReturn(DateTime.now().toIso8601String());
      when(mockUser.updatedAt).thenReturn(DateTime.now().toIso8601String());

      // Act
      final result = await dataSource.signInWithEmailAndPassword(
        'subdomain',
        'test@example.com',
        'password123',
      );

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, isA<UserModel>());
      expect(result.data?.id, 'test_uid');
      expect(result.data?.email, 'test@example.com');
      expect(result.data?.name, 'Test User');
      
      verify(mockGotrueClient.signInWithPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('returns failure when user data is null after sign-in', () async {
      // Arrange
      when(mockGotrueClient.signInWithPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockAuthResponse);

      when(mockAuthResponse.user).thenReturn(null);

      // Act
      final result = await dataSource.signInWithEmailAndPassword(
        'subdomain',
        'test@example.com',
        'password123',
      );

      // Assert
      expect(result.isFailure, true);
      expect(result.error.toString(), contains('Dữ liệu người dùng trống'));
    });

    test('returns failure when Supabase throws exception', () async {
      // Arrange
      final exception = AuthException('Invalid login credentials');
      when(mockGotrueClient.signInWithPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenThrow(exception);

      // Act
      final result = await dataSource.signInWithEmailAndPassword(
        'subdomain',
        'test@example.com',
        'password123',
      );

      // Assert
      expect(result.isFailure, true);
      expect(result.error, exception);
    });
  });

  group('signOut', () {
    test('successfully signs out', () async {
      // Arrange
      when(mockGotrueClient.signOut()).thenAnswer((_) async => {});

      // Act
      final result = await dataSource.signOut();

      // Assert
      expect(result.isSuccess, true);
      verify(mockGotrueClient.signOut()).called(1);
    });

    test('returns failure when signOut throws exception', () async {
      // Arrange
      final exception = Exception('Sign out failed');
      when(mockGotrueClient.signOut()).thenThrow(exception);

      // Act
      final result = await dataSource.signOut();

      // Assert
      expect(result.isFailure, true);
      expect(result.error, exception);
    });
  });

  group('getCurrentUser', () {
    late MockUser mockUser;

    setUp(() {
      mockUser = MockUser();
    });

    test('returns UserModel when a user is signed in', () async {
      // Arrange
      when(mockGotrueClient.currentUser).thenReturn(mockUser);
      when(mockUser.id).thenReturn('test_uid');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.phone).thenReturn('123456');
      when(mockUser.userMetadata).thenReturn({
        'name': 'Test User',
        'avatar_url': 'https://example.com/avatar.png',
      });
      when(mockUser.createdAt).thenReturn(DateTime.now().toIso8601String());
      when(mockUser.updatedAt).thenReturn(DateTime.now().toIso8601String());

      // Act
      final result = await dataSource.getCurrentUser();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, isA<UserModel>());
      expect(result.data?.id, 'test_uid');
      expect(result.data?.email, 'test@example.com');
    });

    test('returns null when no user is signed in', () async {
      // Arrange
      when(mockGotrueClient.currentUser).thenReturn(null);

      // Act
      final result = await dataSource.getCurrentUser();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, null);
    });

    test('returns failure when getCurrentUser throws exception', () async {
      // Arrange
      final exception = Exception('Failed to get current user');
      when(mockGotrueClient.currentUser).thenThrow(exception);

      // Act
      final result = await dataSource.getCurrentUser();

      // Assert
      expect(result.isFailure, true);
      expect(result.error, exception);
    });
  });
}
