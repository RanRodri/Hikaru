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
import 'package:collection/collection.dart';


/** This is an auto generated class representing the Crystal type in your schema. */
class Crystal extends amplify_core.Model {
  static const classType = const _CrystalModelType();
  final String? _code;
  final String? _name;
  final String? _templeName;
  final double? _frequencyHz;
  final String? _primaryPurpose;
  final List<String>? _meridians;
  final String? _audioFileUrl;
  final String? _imageFileUrl;
  final List<User30DayCycle>? _cycles;
  final List<User>? _actualCrystalUsers;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => modelIdentifier.serializeAsString();
  
  CrystalModelIdentifier get modelIdentifier {
    try {
      return CrystalModelIdentifier(
        code: _code!
      );
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get code {
    try {
      return _code!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get name {
    try {
      return _name!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get templeName {
    return _templeName;
  }
  
  double? get frequencyHz {
    return _frequencyHz;
  }
  
  String? get primaryPurpose {
    return _primaryPurpose;
  }
  
  List<String>? get meridians {
    return _meridians;
  }
  
  String? get audioFileUrl {
    return _audioFileUrl;
  }
  
  String? get imageFileUrl {
    return _imageFileUrl;
  }
  
  List<User30DayCycle>? get cycles {
    return _cycles;
  }
  
  List<User>? get actualCrystalUsers {
    return _actualCrystalUsers;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Crystal._internal({required code, required name, templeName, frequencyHz, primaryPurpose, meridians, audioFileUrl, imageFileUrl, cycles, actualCrystalUsers, createdAt, updatedAt}): _code = code, _name = name, _templeName = templeName, _frequencyHz = frequencyHz, _primaryPurpose = primaryPurpose, _meridians = meridians, _audioFileUrl = audioFileUrl, _imageFileUrl = imageFileUrl, _cycles = cycles, _actualCrystalUsers = actualCrystalUsers, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Crystal({required String code, required String name, String? templeName, double? frequencyHz, String? primaryPurpose, List<String>? meridians, String? audioFileUrl, String? imageFileUrl, List<User30DayCycle>? cycles, List<User>? actualCrystalUsers}) {
    return Crystal._internal(
      code: code,
      name: name,
      templeName: templeName,
      frequencyHz: frequencyHz,
      primaryPurpose: primaryPurpose,
      meridians: meridians != null ? List<String>.unmodifiable(meridians) : meridians,
      audioFileUrl: audioFileUrl,
      imageFileUrl: imageFileUrl,
      cycles: cycles != null ? List<User30DayCycle>.unmodifiable(cycles) : cycles,
      actualCrystalUsers: actualCrystalUsers != null ? List<User>.unmodifiable(actualCrystalUsers) : actualCrystalUsers);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Crystal &&
      _code == other._code &&
      _name == other._name &&
      _templeName == other._templeName &&
      _frequencyHz == other._frequencyHz &&
      _primaryPurpose == other._primaryPurpose &&
      DeepCollectionEquality().equals(_meridians, other._meridians) &&
      _audioFileUrl == other._audioFileUrl &&
      _imageFileUrl == other._imageFileUrl &&
      DeepCollectionEquality().equals(_cycles, other._cycles) &&
      DeepCollectionEquality().equals(_actualCrystalUsers, other._actualCrystalUsers);
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Crystal {");
    buffer.write("code=" + "$_code" + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("templeName=" + "$_templeName" + ", ");
    buffer.write("frequencyHz=" + (_frequencyHz != null ? _frequencyHz!.toString() : "null") + ", ");
    buffer.write("primaryPurpose=" + "$_primaryPurpose" + ", ");
    buffer.write("meridians=" + (_meridians != null ? _meridians!.toString() : "null") + ", ");
    buffer.write("audioFileUrl=" + "$_audioFileUrl" + ", ");
    buffer.write("imageFileUrl=" + "$_imageFileUrl" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Crystal copyWith({String? name, String? templeName, double? frequencyHz, String? primaryPurpose, List<String>? meridians, String? audioFileUrl, String? imageFileUrl, List<User30DayCycle>? cycles, List<User>? actualCrystalUsers}) {
    return Crystal._internal(
      code: code,
      name: name ?? this.name,
      templeName: templeName ?? this.templeName,
      frequencyHz: frequencyHz ?? this.frequencyHz,
      primaryPurpose: primaryPurpose ?? this.primaryPurpose,
      meridians: meridians ?? this.meridians,
      audioFileUrl: audioFileUrl ?? this.audioFileUrl,
      imageFileUrl: imageFileUrl ?? this.imageFileUrl,
      cycles: cycles ?? this.cycles,
      actualCrystalUsers: actualCrystalUsers ?? this.actualCrystalUsers);
  }
  
  Crystal copyWithModelFieldValues({
    ModelFieldValue<String>? name,
    ModelFieldValue<String?>? templeName,
    ModelFieldValue<double?>? frequencyHz,
    ModelFieldValue<String?>? primaryPurpose,
    ModelFieldValue<List<String>?>? meridians,
    ModelFieldValue<String?>? audioFileUrl,
    ModelFieldValue<String?>? imageFileUrl,
    ModelFieldValue<List<User30DayCycle>?>? cycles,
    ModelFieldValue<List<User>?>? actualCrystalUsers
  }) {
    return Crystal._internal(
      code: code,
      name: name == null ? this.name : name.value,
      templeName: templeName == null ? this.templeName : templeName.value,
      frequencyHz: frequencyHz == null ? this.frequencyHz : frequencyHz.value,
      primaryPurpose: primaryPurpose == null ? this.primaryPurpose : primaryPurpose.value,
      meridians: meridians == null ? this.meridians : meridians.value,
      audioFileUrl: audioFileUrl == null ? this.audioFileUrl : audioFileUrl.value,
      imageFileUrl: imageFileUrl == null ? this.imageFileUrl : imageFileUrl.value,
      cycles: cycles == null ? this.cycles : cycles.value,
      actualCrystalUsers: actualCrystalUsers == null ? this.actualCrystalUsers : actualCrystalUsers.value
    );
  }
  
  Crystal.fromJson(Map<String, dynamic> json)  
    : _code = json['code'],
      _name = json['name'],
      _templeName = json['templeName'],
      _frequencyHz = (json['frequencyHz'] as num?)?.toDouble(),
      _primaryPurpose = json['primaryPurpose'],
      _meridians = json['meridians']?.cast<String>(),
      _audioFileUrl = json['audioFileUrl'],
      _imageFileUrl = json['imageFileUrl'],
      _cycles = json['cycles']  is Map
        ? (json['cycles']['items'] is List
          ? (json['cycles']['items'] as List)
              .where((e) => e != null)
              .map((e) => User30DayCycle.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['cycles'] is List
          ? (json['cycles'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => User30DayCycle.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null),
      _actualCrystalUsers = json['actualCrystalUsers']  is Map
        ? (json['actualCrystalUsers']['items'] is List
          ? (json['actualCrystalUsers']['items'] as List)
              .where((e) => e != null)
              .map((e) => User.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['actualCrystalUsers'] is List
          ? (json['actualCrystalUsers'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => User.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null),
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'code': _code, 'name': _name, 'templeName': _templeName, 'frequencyHz': _frequencyHz, 'primaryPurpose': _primaryPurpose, 'meridians': _meridians, 'audioFileUrl': _audioFileUrl, 'imageFileUrl': _imageFileUrl, 'cycles': _cycles?.map((User30DayCycle? e) => e?.toJson()).toList(), 'actualCrystalUsers': _actualCrystalUsers?.map((User? e) => e?.toJson()).toList(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'code': _code,
    'name': _name,
    'templeName': _templeName,
    'frequencyHz': _frequencyHz,
    'primaryPurpose': _primaryPurpose,
    'meridians': _meridians,
    'audioFileUrl': _audioFileUrl,
    'imageFileUrl': _imageFileUrl,
    'cycles': _cycles,
    'actualCrystalUsers': _actualCrystalUsers,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<CrystalModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<CrystalModelIdentifier>();
  static final CODE = amplify_core.QueryField(fieldName: "code");
  static final NAME = amplify_core.QueryField(fieldName: "name");
  static final TEMPLENAME = amplify_core.QueryField(fieldName: "templeName");
  static final FREQUENCYHZ = amplify_core.QueryField(fieldName: "frequencyHz");
  static final PRIMARYPURPOSE = amplify_core.QueryField(fieldName: "primaryPurpose");
  static final MERIDIANS = amplify_core.QueryField(fieldName: "meridians");
  static final AUDIOFILEURL = amplify_core.QueryField(fieldName: "audioFileUrl");
  static final IMAGEFILEURL = amplify_core.QueryField(fieldName: "imageFileUrl");
  static final CYCLES = amplify_core.QueryField(
    fieldName: "cycles",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'User30DayCycle'));
  static final ACTUALCRYSTALUSERS = amplify_core.QueryField(
    fieldName: "actualCrystalUsers",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'User'));
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Crystal";
    modelSchemaDefinition.pluralName = "Crystals";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PRIVATE,
        operations: const [
          amplify_core.ModelOperation.READ
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
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["code"], name: null)
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Crystal.CODE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Crystal.NAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Crystal.TEMPLENAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Crystal.FREQUENCYHZ,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Crystal.PRIMARYPURPOSE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Crystal.MERIDIANS,
      isRequired: false,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Crystal.AUDIOFILEURL,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Crystal.IMAGEFILEURL,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: Crystal.CYCLES,
      isRequired: false,
      ofModelName: 'User30DayCycle',
      associatedKey: User30DayCycle.CRYSTAL
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: Crystal.ACTUALCRYSTALUSERS,
      isRequired: false,
      ofModelName: 'User',
      associatedKey: User.ACTUALCRYSTAL
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

class _CrystalModelType extends amplify_core.ModelType<Crystal> {
  const _CrystalModelType();
  
  @override
  Crystal fromJson(Map<String, dynamic> jsonData) {
    return Crystal.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Crystal';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Crystal] in your schema.
 */
class CrystalModelIdentifier implements amplify_core.ModelIdentifier<Crystal> {
  final String code;

  /** Create an instance of CrystalModelIdentifier using [code] the primary key. */
  const CrystalModelIdentifier({
    required this.code});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'code': code
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'CrystalModelIdentifier(code: $code)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is CrystalModelIdentifier &&
      code == other.code;
  }
  
  @override
  int get hashCode =>
    code.hashCode;
}