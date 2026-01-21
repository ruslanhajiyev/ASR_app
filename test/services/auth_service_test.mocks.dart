
import 'dart:async' as _i5;

import 'package:asr_app/models/models.dart' as _i2;
import 'package:asr_app/services/mock_backend_service.dart' as _i4;
import 'package:flutter/services.dart' as _i6;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i3;
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

class _FakeIOSOptions_2 extends _i1.SmartFake implements _i3.IOSOptions {
  _FakeIOSOptions_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeAndroidOptions_3 extends _i1.SmartFake
    implements _i3.AndroidOptions {
  _FakeAndroidOptions_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeLinuxOptions_4 extends _i1.SmartFake implements _i3.LinuxOptions {
  _FakeLinuxOptions_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWindowsOptions_5 extends _i1.SmartFake
    implements _i3.WindowsOptions {
  _FakeWindowsOptions_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWebOptions_6 extends _i1.SmartFake implements _i3.WebOptions {
  _FakeWebOptions_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeMacOsOptions_7 extends _i1.SmartFake implements _i3.MacOsOptions {
  _FakeMacOsOptions_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}




class MockMockBackendService extends _i1.Mock
    implements _i4.MockBackendService {
  MockMockBackendService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<_i2.AuthResponse> register({
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
        returnValue: _i5.Future<_i2.AuthResponse>.value(_FakeAuthResponse_0(
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
      ) as _i5.Future<_i2.AuthResponse>);

  @override
  _i5.Future<_i2.AuthResponse> login({
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
        returnValue: _i5.Future<_i2.AuthResponse>.value(_FakeAuthResponse_0(
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
      ) as _i5.Future<_i2.AuthResponse>);

  @override
  _i5.Future<_i2.User?> getCurrentUser(String? token) => (super.noSuchMethod(
        Invocation.method(
          #getCurrentUser,
          [token],
        ),
        returnValue: _i5.Future<_i2.User?>.value(),
      ) as _i5.Future<_i2.User?>);

  @override
  _i5.Future<void> logout(String? token) => (super.noSuchMethod(
        Invocation.method(
          #logout,
          [token],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<_i2.Submission> createSubmission({
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
        returnValue: _i5.Future<_i2.Submission>.value(_FakeSubmission_1(
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
      ) as _i5.Future<_i2.Submission>);

  @override
  _i5.Future<List<_i2.Submission>> getSubmissions(
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
        returnValue: _i5.Future<List<_i2.Submission>>.value(<_i2.Submission>[]),
      ) as _i5.Future<List<_i2.Submission>>);

  @override
  _i5.Future<_i2.Submission> updateSubmissionStatus(
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
        returnValue: _i5.Future<_i2.Submission>.value(_FakeSubmission_1(
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
      ) as _i5.Future<_i2.Submission>);

  @override
  _i5.Future<void> clearUserSubmissions(String? userId) => (super.noSuchMethod(
        Invocation.method(
          #clearUserSubmissions,
          [userId],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}


class MockFlutterSecureStorage extends _i1.Mock
    implements _i3.FlutterSecureStorage {
  MockFlutterSecureStorage() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.IOSOptions get iOptions => (super.noSuchMethod(
        Invocation.getter(#iOptions),
        returnValue: _FakeIOSOptions_2(
          this,
          Invocation.getter(#iOptions),
        ),
      ) as _i3.IOSOptions);

  @override
  _i3.AndroidOptions get aOptions => (super.noSuchMethod(
        Invocation.getter(#aOptions),
        returnValue: _FakeAndroidOptions_3(
          this,
          Invocation.getter(#aOptions),
        ),
      ) as _i3.AndroidOptions);

  @override
  _i3.LinuxOptions get lOptions => (super.noSuchMethod(
        Invocation.getter(#lOptions),
        returnValue: _FakeLinuxOptions_4(
          this,
          Invocation.getter(#lOptions),
        ),
      ) as _i3.LinuxOptions);

  @override
  _i3.WindowsOptions get wOptions => (super.noSuchMethod(
        Invocation.getter(#wOptions),
        returnValue: _FakeWindowsOptions_5(
          this,
          Invocation.getter(#wOptions),
        ),
      ) as _i3.WindowsOptions);

  @override
  _i3.WebOptions get webOptions => (super.noSuchMethod(
        Invocation.getter(#webOptions),
        returnValue: _FakeWebOptions_6(
          this,
          Invocation.getter(#webOptions),
        ),
      ) as _i3.WebOptions);

  @override
  _i3.MacOsOptions get mOptions => (super.noSuchMethod(
        Invocation.getter(#mOptions),
        returnValue: _FakeMacOsOptions_7(
          this,
          Invocation.getter(#mOptions),
        ),
      ) as _i3.MacOsOptions);

  @override
  void registerListener({
    required String? key,
    required _i6.ValueChanged<String?>? listener,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #registerListener,
          [],
          {
            #key: key,
            #listener: listener,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  void unregisterListener({
    required String? key,
    required _i6.ValueChanged<String?>? listener,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #unregisterListener,
          [],
          {
            #key: key,
            #listener: listener,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  void unregisterAllListenersForKey({required String? key}) =>
      super.noSuchMethod(
        Invocation.method(
          #unregisterAllListenersForKey,
          [],
          {#key: key},
        ),
        returnValueForMissingStub: null,
      );

  @override
  void unregisterAllListeners() => super.noSuchMethod(
        Invocation.method(
          #unregisterAllListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i5.Future<void> write({
    required String? key,
    required String? value,
    _i3.IOSOptions? iOptions,
    _i3.AndroidOptions? aOptions,
    _i3.LinuxOptions? lOptions,
    _i3.WebOptions? webOptions,
    _i3.MacOsOptions? mOptions,
    _i3.WindowsOptions? wOptions,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #write,
          [],
          {
            #key: key,
            #value: value,
            #iOptions: iOptions,
            #aOptions: aOptions,
            #lOptions: lOptions,
            #webOptions: webOptions,
            #mOptions: mOptions,
            #wOptions: wOptions,
          },
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<String?> read({
    required String? key,
    _i3.IOSOptions? iOptions,
    _i3.AndroidOptions? aOptions,
    _i3.LinuxOptions? lOptions,
    _i3.WebOptions? webOptions,
    _i3.MacOsOptions? mOptions,
    _i3.WindowsOptions? wOptions,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #read,
          [],
          {
            #key: key,
            #iOptions: iOptions,
            #aOptions: aOptions,
            #lOptions: lOptions,
            #webOptions: webOptions,
            #mOptions: mOptions,
            #wOptions: wOptions,
          },
        ),
        returnValue: _i5.Future<String?>.value(),
      ) as _i5.Future<String?>);

  @override
  _i5.Future<bool> containsKey({
    required String? key,
    _i3.IOSOptions? iOptions,
    _i3.AndroidOptions? aOptions,
    _i3.LinuxOptions? lOptions,
    _i3.WebOptions? webOptions,
    _i3.MacOsOptions? mOptions,
    _i3.WindowsOptions? wOptions,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #containsKey,
          [],
          {
            #key: key,
            #iOptions: iOptions,
            #aOptions: aOptions,
            #lOptions: lOptions,
            #webOptions: webOptions,
            #mOptions: mOptions,
            #wOptions: wOptions,
          },
        ),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  _i5.Future<void> delete({
    required String? key,
    _i3.IOSOptions? iOptions,
    _i3.AndroidOptions? aOptions,
    _i3.LinuxOptions? lOptions,
    _i3.WebOptions? webOptions,
    _i3.MacOsOptions? mOptions,
    _i3.WindowsOptions? wOptions,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #delete,
          [],
          {
            #key: key,
            #iOptions: iOptions,
            #aOptions: aOptions,
            #lOptions: lOptions,
            #webOptions: webOptions,
            #mOptions: mOptions,
            #wOptions: wOptions,
          },
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<Map<String, String>> readAll({
    _i3.IOSOptions? iOptions,
    _i3.AndroidOptions? aOptions,
    _i3.LinuxOptions? lOptions,
    _i3.WebOptions? webOptions,
    _i3.MacOsOptions? mOptions,
    _i3.WindowsOptions? wOptions,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #readAll,
          [],
          {
            #iOptions: iOptions,
            #aOptions: aOptions,
            #lOptions: lOptions,
            #webOptions: webOptions,
            #mOptions: mOptions,
            #wOptions: wOptions,
          },
        ),
        returnValue: _i5.Future<Map<String, String>>.value(<String, String>{}),
      ) as _i5.Future<Map<String, String>>);

  @override
  _i5.Future<void> deleteAll({
    _i3.IOSOptions? iOptions,
    _i3.AndroidOptions? aOptions,
    _i3.LinuxOptions? lOptions,
    _i3.WebOptions? webOptions,
    _i3.MacOsOptions? mOptions,
    _i3.WindowsOptions? wOptions,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteAll,
          [],
          {
            #iOptions: iOptions,
            #aOptions: aOptions,
            #lOptions: lOptions,
            #webOptions: webOptions,
            #mOptions: mOptions,
            #wOptions: wOptions,
          },
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<bool?> isCupertinoProtectedDataAvailable() => (super.noSuchMethod(
        Invocation.method(
          #isCupertinoProtectedDataAvailable,
          [],
        ),
        returnValue: _i5.Future<bool?>.value(),
      ) as _i5.Future<bool?>);
}
