/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;


/** This is an auto generated class representing the UserSubscription type in your schema. */
class UserSubscription extends amplify_core.Model {
  static const classType = const _UserSubscriptionModelType();
  final String id;
  final PlanTier? _planTier;
  final StoreProvider? _storeProvider;
  final String? _originalTransactionId;
  final SubscriptionStatus? _status;
  final amplify_core.TemporalDateTime? _expiresAt;
  final User? _user;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  UserSubscriptionModelIdentifier get modelIdentifier {
      return UserSubscriptionModelIdentifier(
        id: id
      );
  }
  
  PlanTier get planTier {
    try {
      return _planTier!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  StoreProvider get storeProvider {
    try {
      return _storeProvider!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get originalTransactionId {
    return _originalTransactionId;
  }
  
  SubscriptionStatus get status {
    try {
      return _status!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime? get expiresAt {
    return _expiresAt;
  }
  
  User? get user {
    return _user;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const UserSubscription._internal({required this.id, required planTier, required storeProvider, originalTransactionId, required status, expiresAt, user, createdAt, updatedAt}): _planTier = planTier, _storeProvider = storeProvider, _originalTransactionId = originalTransactionId, _status = status, _expiresAt = expiresAt, _user = user, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory UserSubscription({String? id, required PlanTier planTier, required StoreProvider storeProvider, String? originalTransactionId, required SubscriptionStatus status, amplify_core.TemporalDateTime? expiresAt, User? user}) {
    return UserSubscription._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      planTier: planTier,
      storeProvider: storeProvider,
      originalTransactionId: originalTransactionId,
      status: status,
      expiresAt: expiresAt,
      user: user);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserSubscription &&
      id == other.id &&
      _planTier == other._planTier &&
      _storeProvider == other._storeProvider &&
      _originalTransactionId == other._originalTransactionId &&
      _status == other._status &&
      _expiresAt == other._expiresAt &&
      _user == other._user;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("UserSubscription {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("planTier=" + (_planTier != null ? amplify_core.enumToString(_planTier)! : "null") + ", ");
    buffer.write("storeProvider=" + (_storeProvider != null ? amplify_core.enumToString(_storeProvider)! : "null") + ", ");
    buffer.write("originalTransactionId=" + "$_originalTransactionId" + ", ");
    buffer.write("status=" + (_status != null ? amplify_core.enumToString(_status)! : "null") + ", ");
    buffer.write("expiresAt=" + (_expiresAt != null ? _expiresAt!.format() : "null") + ", ");
    buffer.write("user=" + (_user != null ? _user!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  UserSubscription copyWith({PlanTier? planTier, StoreProvider? storeProvider, String? originalTransactionId, SubscriptionStatus? status, amplify_core.TemporalDateTime? expiresAt, User? user}) {
    return UserSubscription._internal(
      id: id,
      planTier: planTier ?? this.planTier,
      storeProvider: storeProvider ?? this.storeProvider,
      originalTransactionId: originalTransactionId ?? this.originalTransactionId,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      user: user ?? this.user);
  }
  
  UserSubscription copyWithModelFieldValues({
    ModelFieldValue<PlanTier>? planTier,
    ModelFieldValue<StoreProvider>? storeProvider,
    ModelFieldValue<String?>? originalTransactionId,
    ModelFieldValue<SubscriptionStatus>? status,
    ModelFieldValue<amplify_core.TemporalDateTime?>? expiresAt,
    ModelFieldValue<User?>? user
  }) {
    return UserSubscription._internal(
      id: id,
      planTier: planTier == null ? this.planTier : planTier.value,
      storeProvider: storeProvider == null ? this.storeProvider : storeProvider.value,
      originalTransactionId: originalTransactionId == null ? this.originalTransactionId : originalTransactionId.value,
      status: status == null ? this.status : status.value,
      expiresAt: expiresAt == null ? this.expiresAt : expiresAt.value,
      user: user == null ? this.user : user.value
    );
  }
  
  UserSubscription.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _planTier = amplify_core.enumFromString<PlanTier>(json['planTier'], PlanTier.values),
      _storeProvider = amplify_core.enumFromString<StoreProvider>(json['storeProvider'], StoreProvider.values),
      _originalTransactionId = json['originalTransactionId'],
      _status = amplify_core.enumFromString<SubscriptionStatus>(json['status'], SubscriptionStatus.values),
      _expiresAt = json['expiresAt'] != null ? amplify_core.TemporalDateTime.fromString(json['expiresAt']) : null,
      _user = json['user'] != null
        ? json['user']['serializedData'] != null
          ? User.fromJson(new Map<String, dynamic>.from(json['user']['serializedData']))
          : User.fromJson(new Map<String, dynamic>.from(json['user']))
        : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'planTier': amplify_core.enumToString(_planTier), 'storeProvider': amplify_core.enumToString(_storeProvider), 'originalTransactionId': _originalTransactionId, 'status': amplify_core.enumToString(_status), 'expiresAt': _expiresAt?.format(), 'user': _user?.toJson(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'planTier': _planTier,
    'storeProvider': _storeProvider,
    'originalTransactionId': _originalTransactionId,
    'status': _status,
    'expiresAt': _expiresAt,
    'user': _user,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<UserSubscriptionModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<UserSubscriptionModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final PLANTIER = amplify_core.QueryField(fieldName: "planTier");
  static final STOREPROVIDER = amplify_core.QueryField(fieldName: "storeProvider");
  static final ORIGINALTRANSACTIONID = amplify_core.QueryField(fieldName: "originalTransactionId");
  static final STATUS = amplify_core.QueryField(fieldName: "status");
  static final EXPIRESAT = amplify_core.QueryField(fieldName: "expiresAt");
  static final USER = amplify_core.QueryField(
    fieldName: "user",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'User'));
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "UserSubscription";
    modelSchemaDefinition.pluralName = "UserSubscriptions";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.OWNER,
        ownerField: "owner",
        identityClaim: "cognito:username",
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.READ,
          amplify_core.ModelOperation.CREATE
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.GROUPS,
        groupClaim: "cognito:groups",
        groups: [ "Admins" ],
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.READ,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserSubscription.PLANTIER,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserSubscription.STOREPROVIDER,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserSubscription.ORIGINALTRANSACTIONID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserSubscription.STATUS,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserSubscription.EXPIRESAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: UserSubscription.USER,
      isRequired: false,
      targetNames: ['userId'],
      ofModelName: 'User'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _UserSubscriptionModelType extends amplify_core.ModelType<UserSubscription> {
  const _UserSubscriptionModelType();
  
  @override
  UserSubscription fromJson(Map<String, dynamic> jsonData) {
    return UserSubscription.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'UserSubscription';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [UserSubscription] in your schema.
 */
class UserSubscriptionModelIdentifier implements amplify_core.ModelIdentifier<UserSubscription> {
  final String id;

  /** Create an instance of UserSubscriptionModelIdentifier using [id] the primary key. */
  const UserSubscriptionModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'UserSubscriptionModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is UserSubscriptionModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}