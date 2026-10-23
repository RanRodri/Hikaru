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


/** This is an auto generated class representing the ReflectionPhoto type in your schema. */
class ReflectionPhoto extends amplify_core.Model {
  static const classType = const _ReflectionPhotoModelType();
  final String id;
  final int? _dayNumber;
  final String? _s3EncryptedKey;
  final amplify_core.TemporalDateTime? _uploadedAt;
  final User? _user;
  final User30DayCycle? _cycle;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  ReflectionPhotoModelIdentifier get modelIdentifier {
      return ReflectionPhotoModelIdentifier(
        id: id
      );
  }
  
  int get dayNumber {
    try {
      return _dayNumber!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get s3EncryptedKey {
    try {
      return _s3EncryptedKey!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get uploadedAt {
    try {
      return _uploadedAt!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  User? get user {
    return _user;
  }
  
  User30DayCycle? get cycle {
    return _cycle;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const ReflectionPhoto._internal({required this.id, required dayNumber, required s3EncryptedKey, required uploadedAt, user, cycle, createdAt, updatedAt}): _dayNumber = dayNumber, _s3EncryptedKey = s3EncryptedKey, _uploadedAt = uploadedAt, _user = user, _cycle = cycle, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory ReflectionPhoto({String? id, required int dayNumber, required String s3EncryptedKey, required amplify_core.TemporalDateTime uploadedAt, User? user, User30DayCycle? cycle}) {
    return ReflectionPhoto._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      dayNumber: dayNumber,
      s3EncryptedKey: s3EncryptedKey,
      uploadedAt: uploadedAt,
      user: user,
      cycle: cycle);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReflectionPhoto &&
      id == other.id &&
      _dayNumber == other._dayNumber &&
      _s3EncryptedKey == other._s3EncryptedKey &&
      _uploadedAt == other._uploadedAt &&
      _user == other._user &&
      _cycle == other._cycle;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("ReflectionPhoto {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("dayNumber=" + (_dayNumber != null ? _dayNumber!.toString() : "null") + ", ");
    buffer.write("s3EncryptedKey=" + "$_s3EncryptedKey" + ", ");
    buffer.write("uploadedAt=" + (_uploadedAt != null ? _uploadedAt!.format() : "null") + ", ");
    buffer.write("user=" + (_user != null ? _user!.toString() : "null") + ", ");
    buffer.write("cycle=" + (_cycle != null ? _cycle!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  ReflectionPhoto copyWith({int? dayNumber, String? s3EncryptedKey, amplify_core.TemporalDateTime? uploadedAt, User? user, User30DayCycle? cycle}) {
    return ReflectionPhoto._internal(
      id: id,
      dayNumber: dayNumber ?? this.dayNumber,
      s3EncryptedKey: s3EncryptedKey ?? this.s3EncryptedKey,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      user: user ?? this.user,
      cycle: cycle ?? this.cycle);
  }
  
  ReflectionPhoto copyWithModelFieldValues({
    ModelFieldValue<int>? dayNumber,
    ModelFieldValue<String>? s3EncryptedKey,
    ModelFieldValue<amplify_core.TemporalDateTime>? uploadedAt,
    ModelFieldValue<User?>? user,
    ModelFieldValue<User30DayCycle?>? cycle
  }) {
    return ReflectionPhoto._internal(
      id: id,
      dayNumber: dayNumber == null ? this.dayNumber : dayNumber.value,
      s3EncryptedKey: s3EncryptedKey == null ? this.s3EncryptedKey : s3EncryptedKey.value,
      uploadedAt: uploadedAt == null ? this.uploadedAt : uploadedAt.value,
      user: user == null ? this.user : user.value,
      cycle: cycle == null ? this.cycle : cycle.value
    );
  }
  
  ReflectionPhoto.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _dayNumber = (json['dayNumber'] as num?)?.toInt(),
      _s3EncryptedKey = json['s3EncryptedKey'],
      _uploadedAt = json['uploadedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['uploadedAt']) : null,
      _user = json['user'] != null
        ? json['user']['serializedData'] != null
          ? User.fromJson(new Map<String, dynamic>.from(json['user']['serializedData']))
          : User.fromJson(new Map<String, dynamic>.from(json['user']))
        : null,
      _cycle = json['cycle'] != null
        ? json['cycle']['serializedData'] != null
          ? User30DayCycle.fromJson(new Map<String, dynamic>.from(json['cycle']['serializedData']))
          : User30DayCycle.fromJson(new Map<String, dynamic>.from(json['cycle']))
        : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'dayNumber': _dayNumber, 's3EncryptedKey': _s3EncryptedKey, 'uploadedAt': _uploadedAt?.format(), 'user': _user?.toJson(), 'cycle': _cycle?.toJson(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'dayNumber': _dayNumber,
    's3EncryptedKey': _s3EncryptedKey,
    'uploadedAt': _uploadedAt,
    'user': _user,
    'cycle': _cycle,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<ReflectionPhotoModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<ReflectionPhotoModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final DAYNUMBER = amplify_core.QueryField(fieldName: "dayNumber");
  static final S3ENCRYPTEDKEY = amplify_core.QueryField(fieldName: "s3EncryptedKey");
  static final UPLOADEDAT = amplify_core.QueryField(fieldName: "uploadedAt");
  static final USER = amplify_core.QueryField(
    fieldName: "user",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'User'));
  static final CYCLE = amplify_core.QueryField(
    fieldName: "cycle",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'User30DayCycle'));
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "ReflectionPhoto";
    modelSchemaDefinition.pluralName = "ReflectionPhotos";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.OWNER,
        ownerField: "owner",
        identityClaim: "cognito:username",
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.GROUPS,
        groupClaim: "cognito:groups",
        groups: [ "Admins" ],
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.READ,
          amplify_core.ModelOperation.DELETE
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ReflectionPhoto.DAYNUMBER,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ReflectionPhoto.S3ENCRYPTEDKEY,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ReflectionPhoto.UPLOADEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: ReflectionPhoto.USER,
      isRequired: false,
      targetNames: ['userId'],
      ofModelName: 'User'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: ReflectionPhoto.CYCLE,
      isRequired: false,
      targetNames: ['cycleId'],
      ofModelName: 'User30DayCycle'
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

class _ReflectionPhotoModelType extends amplify_core.ModelType<ReflectionPhoto> {
  const _ReflectionPhotoModelType();
  
  @override
  ReflectionPhoto fromJson(Map<String, dynamic> jsonData) {
    return ReflectionPhoto.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'ReflectionPhoto';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [ReflectionPhoto] in your schema.
 */
class ReflectionPhotoModelIdentifier implements amplify_core.ModelIdentifier<ReflectionPhoto> {
  final String id;

  /** Create an instance of ReflectionPhotoModelIdentifier using [id] the primary key. */
  const ReflectionPhotoModelIdentifier({
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
  String toString() => 'ReflectionPhotoModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is ReflectionPhotoModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}