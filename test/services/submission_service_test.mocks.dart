import 'dart:async' as _i4;

import 'package:asr_app/models/models.dart' as _i2;
import 'package:asr_app/services/auth_service.dart' as _i5;
import 'package:asr_app/services/mock_backend_service.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;

class _FakeAuthResponse_0 extends _i1.SmartFake implements _i2.AuthResponse {
  _FakeAuthResponse_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSubmission_1 extends _i1.SmartFake implements _i2.Submission {
  _FakeSubmission_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class MockMockBackendService extends _i1.Mock
    implements _i3.MockBackendService {
  MockMockBackendService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i2.AuthResponse> register({
    required String? username,
    required String? password,
    required String? email,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #register,
          [],
          {
            #username: username,
            #password: password,
            #email: email,
          },
        ),
        returnValue: _i4.Future<_i2.AuthResponse>.value(_FakeAuthResponse_0(
          this,
          Invocation.method(
            #register,
            [],
            {
              #username: username,
              #password: password,
              #email: email,
            },
          ),
        )),
      ) as _i4.Future<_i2.AuthResponse>);

  @override
  _i4.Future<_i2.AuthResponse> login({
    required String? username,
    required String? password,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #login,
          [],
          {
            #username: username,
            #password: password,
          },
        ),
        returnValue: _i4.Future<_i2.AuthResponse>.value(_FakeAuthResponse_0(
          this,
          Invocation.method(
            #login,
            [],
            {
              #username: username,
              #password: password,
            },
          ),
        )),
      ) as _i4.Future<_i2.AuthResponse>);

  @override
  _i4.Future<_i2.User?> getCurrentUser(String? token) => (super.noSuchMethod(
        Invocation.method(
          #getCurrentUser,
          [token],
        ),
        returnValue: _i4.Future<_i2.User?>.value(),
      ) as _i4.Future<_i2.User?>);

  @override
  _i4.Future<void> logout(String? token) => (super.noSuchMethod(
        Invocation.method(
          #logout,
          [token],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<_i2.Submission> createSubmission({
    required String? userId,
    required _i2.SubmissionType? type,
    required String? transcriptFinal,
    String? transcriptDraft,
    List<String>? labels,
    String? audioPath,
    Map<String, dynamic>? metadata,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #createSubmission,
          [],
          {
            #userId: userId,
            #type: type,
            #transcriptFinal: transcriptFinal,
            #transcriptDraft: transcriptDraft,
            #labels: labels,
            #audioPath: audioPath,
            #metadata: metadata,
          },
        ),
        returnValue: _i4.Future<_i2.Submission>.value(_FakeSubmission_1(
          this,
          Invocation.method(
            #createSubmission,
            [],
            {
              #userId: userId,
              #type: type,
              #transcriptFinal: transcriptFinal,
              #transcriptDraft: transcriptDraft,
              #labels: labels,
              #audioPath: audioPath,
              #metadata: metadata,
            },
          ),
        )),
      ) as _i4.Future<_i2.Submission>);

  @override
  _i4.Future<List<_i2.Submission>> getSubmissions(
    String? userId,
    String? token,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #getSubmissions,
          [
            userId,
            token,
          ],
        ),
        returnValue: _i4.Future<List<_i2.Submission>>.value(<_i2.Submission>[]),
      ) as _i4.Future<List<_i2.Submission>>);

  @override
  _i4.Future<_i2.Submission> updateSubmissionStatus(
    String? submissionId,
    _i2.SubmissionStatus? status, {
    String? errorMessage,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateSubmissionStatus,
          [
            submissionId,
            status,
          ],
          {#errorMessage: errorMessage},
        ),
        returnValue: _i4.Future<_i2.Submission>.value(_FakeSubmission_1(
          this,
          Invocation.method(
            #updateSubmissionStatus,
            [
              submissionId,
              status,
            ],
            {#errorMessage: errorMessage},
          ),
        )),
      ) as _i4.Future<_i2.Submission>);

  @override
  _i4.Future<void> clearUserSubmissions(String? userId) => (super.noSuchMethod(
        Invocation.method(
          #clearUserSubmissions,
          [userId],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
}

class MockAuthService extends _i1.Mock implements _i5.AuthService {
  MockAuthService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i2.AuthResponse> register({
    required String? username,
    required String? password,
    required String? email,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #register,
          [],
          {
            #username: username,
            #password: password,
            #email: email,
          },
        ),
        returnValue: _i4.Future<_i2.AuthResponse>.value(_FakeAuthResponse_0(
          this,
          Invocation.method(
            #register,
            [],
            {
              #username: username,
              #password: password,
              #email: email,
            },
          ),
        )),
      ) as _i4.Future<_i2.AuthResponse>);

  @override
  _i4.Future<_i2.AuthResponse> login({
    required String? username,
    required String? password,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #login,
          [],
          {
            #username: username,
            #password: password,
          },
        ),
        returnValue: _i4.Future<_i2.AuthResponse>.value(_FakeAuthResponse_0(
          this,
          Invocation.method(
            #login,
            [],
            {
              #username: username,
              #password: password,
            },
          ),
        )),
      ) as _i4.Future<_i2.AuthResponse>);

  @override
  _i4.Future<void> logout() => (super.noSuchMethod(
        Invocation.method(
          #logout,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<String?> getToken() => (super.noSuchMethod(
        Invocation.method(
          #getToken,
          [],
        ),
        returnValue: _i4.Future<String?>.value(),
      ) as _i4.Future<String?>);

  @override
  _i4.Future<String?> getUserId() => (super.noSuchMethod(
        Invocation.method(
          #getUserId,
          [],
        ),
        returnValue: _i4.Future<String?>.value(),
      ) as _i4.Future<String?>);

  @override
  _i4.Future<_i2.User?> getCurrentUser() => (super.noSuchMethod(
        Invocation.method(
          #getCurrentUser,
          [],
        ),
        returnValue: _i4.Future<_i2.User?>.value(),
      ) as _i4.Future<_i2.User?>);

  @override
  _i4.Future<bool> isAuthenticated() => (super.noSuchMethod(
        Invocation.method(
          #isAuthenticated,
          [],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);
}
