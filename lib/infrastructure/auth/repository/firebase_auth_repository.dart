import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/invalid_credentials_cause.dart';
import 'package:parcel_atlas/core/cause/not_member_cause.dart';
import 'package:parcel_atlas/core/cause/unknown_cause.dart';
import 'package:parcel_atlas/core/exception/auth_exception.dart';
import 'package:parcel_atlas/core/exception/network_exception.dart';
import 'package:parcel_atlas/core/logger/local_logger.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/auth/value_object/credentials_value_object.dart';
import 'package:parcel_atlas/infrastructure/auth/mapper/member_document_mapper.dart';
import 'package:parcel_atlas/infrastructure/constants.dart';
import 'package:parcel_atlas/infrastructure/store/service/firestore_store_service.dart';
import 'package:parcel_atlas/infrastructure/store/service/store_collection.dart';

/// Fixed family accounts on Firebase Auth (e-mail/password).
///
/// A member types a short username; it becomes
/// `<username>@members.parcel-atlas.app` here and nowhere else. Signing in is
/// not enough to be a member: the account must also have a profile in
/// `members/` — which only `tool/add_member.dart` writes and which
/// `firestore.rules` lets only listed accounts read. An account without one
/// is signed straight back out and told so.
///
/// [watchMember] follows Firebase's sign-in state, reads the profile, and
/// keeps [currentMember] in step for use cases stamping a change.
class FirebaseAuthRepository implements AuthRepositoryInterface {
  FirebaseAuthRepository(this._auth, this._store);

  final FirebaseAuth _auth;

  final FirestoreStoreService _store;

  static const MemberDocumentMapper _mapper = MemberDocumentMapper();

  static const Set<String> _wrongCredentials = <String>{
    'invalid-credential',
    'wrong-password',
    'user-not-found',
    'invalid-email',
    'user-disabled',
  };

  static const String _network = 'network-request-failed';

  MemberEntity? _current;

  @override
  MemberEntity? get currentMember => _current;

  @override
  Stream<MemberEntity?> watchMember() =>
      _auth.authStateChanges().asyncMap((User? user) async {
        if (user == null) return _current = null;
        final Either<BaseException, MemberEntity> member = await _profile(user);
        return _current = member.isRight ? member.right : null;
      });

  @override
  Future<Either<BaseException, MemberEntity>> signIn(
    CredentialsValueObject credentials,
  ) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email:
            '${credentials.username}@${InfrastructureConstants.memberEmailDomain}',
        password: credentials.password,
      );
      final Either<BaseException, MemberEntity> member = await _profile(
        result.user!,
      );
      if (member.isLeft) await _auth.signOut();
      return member;
    } on FirebaseAuthException catch (e) {
      LocalLogger.warning(e.code);
      return Left(
        _wrongCredentials.contains(e.code)
            ? AuthException(cause: InvalidCredentialsCause())
            : e.code == _network
            ? NetworkException(cause: UnknownCause(cause: e.code))
            : AuthException(cause: UnknownCause(cause: e.code)),
      );
    }
  }

  Future<Either<BaseException, MemberEntity>> _profile(User user) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _store
          .doc(StoreCollection.members, user.uid)
          .get();
      final Map<String, dynamic>? data = doc.data();
      if (data == null) return Left(AuthException(cause: NotMemberCause()));
      return Right(_current = _mapper.read(user.uid, data));
    } catch (e) {
      return Left(_store.failure(e));
    }
  }

  @override
  Future<void> signOut() async {
    _current = null;
    await _auth.signOut();
  }
}
