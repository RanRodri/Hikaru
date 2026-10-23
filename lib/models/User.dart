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


/** This is an auto generated class representing the User type in your schema. */
class User extends amplify_core.Model {
  static const classType = const _UserModelType();
  final String id;
  final String? _email;
  final String? _fullName;
  final amplify_core.TemporalDate? _birthDate;
  final String? _country;
  final DeviceOwnershipStatus? _deviceOwnershipStatus;
  final bool? _biometricsEnabled;
  final bool? _morningSacredRitualEnabled;
  final bool? _eveningReflectionAndBreath;
  final String? _profileOwner;
  final List<User30DayCycle>? _cycles;
  final List<DailyRitual>? _dailyRituals;
  final List<ReflectionPhoto>? _reflectionPhotos;
  final List<QuestionnaireResponse>? _questionnaireResponses;
  final List<UserSubscription>? _subscriptions;
  final Crystal? _actualCrystal;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  UserModelIdentifier get modelIdentifier {
      return UserModelIdentifier(
        id: id
      );
  }
  
  String get email {
    try {
      return _email!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get fullName {
    try {
      return _fullName!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDate? get birthDate {
    return _birthDate;
  }
  
  String? get country {
    return _country;
  }
  
  DeviceOwnershipStatus get deviceOwnershipStatus {
    try {
      return _deviceOwnershipStatus!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  bool get biometricsEnabled {
    try {
      return _biometricsEnabled!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  bool get morningSacredRitualEnabled {
    try {
      return _morningSacredRitualEnabled!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  bool get eveningReflectionAndBreath {
    try {
      return _eveningReflectionAndBreath!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get profileOwner {
    try {
      return _profileOwner!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<User30DayCycle>? get cycles {
    return _cycles;
  }
  
  List<DailyRitual>? get dailyRituals {
    return _dailyRituals;
  }
  
  List<ReflectionPhoto>? get reflectionPhotos {
    return _reflectionPhotos;
  }
  
  List<QuestionnaireResponse>? get questionnaireResponses {
    return _questionnaireResponses;
  }
  
  List<UserSubscription>? get subscriptions {
    return _subscriptions;
  }
  
  Crystal? get actualCrystal {
    return _actualCrystal;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const User._internal({required this.id, required email, required fullName, birthDate, country, required deviceOwnershipStatus, required biometricsEnabled, required morningSacredRitualEnabled, required eveningReflectionAndBreath, required profileOwner, cycles, dailyRituals, reflectionPhotos, questionnaireResponses, subscriptions, actualCrystal, createdAt, updatedAt}): _email = email, _fullName = fullName, _birthDate = birthDate, _country = country, _deviceOwnershipStatus = deviceOwnershipStatus, _biometricsEnabled = biometricsEnabled, _morningSacredRitualEnabled = morningSacredRitualEnabled, _eveningReflectionAndBreath = eveningReflectionAndBreath, _profileOwner = profileOwner, _cycles = cycles, _dailyRituals = dailyRituals, _reflectionPhotos = reflectionPhotos, _questionnaireResponses = questionnaireResponses, _subscriptions = subscriptions, _actualCrystal = actualCrystal, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory User({String? id, required String email, required String fullName, amplify_core.TemporalDate? birthDate, String? country, required DeviceOwnershipStatus deviceOwnershipStatus, required bool biometricsEnabled, required bool morningSacredRitualEnabled, required bool eveningReflectionAndBreath, required String profileOwner, List<User30DayCycle>? cycles, List<DailyRitual>? dailyRituals, List<ReflectionPhoto>? reflectionPhotos, List<QuestionnaireResponse>? questionnaireResponses, List<UserSubscription>? subscriptions, Crystal? actualCrystal}) {
    return User._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      email: email,
      fullName: fullName,
      birthDate: birthDate,
      country: country,
      deviceOwnershipStatus: deviceOwnershipStatus,
      biometricsEnabled: biometricsEnabled,
      morningSacredRitualEnabled: morningSacredRitualEnabled,
      eveningReflectionAndBreath: eveningReflectionAndBreath,
      profileOwner: profileOwner,
      cycles: cycles != null ? List<User30DayCycle>.unmodifiable(cycles) : cycles,
      dailyRituals: dailyRituals != null ? List<DailyRitual>.unmodifiable(dailyRituals) : dailyRituals,
      reflectionPhotos: reflectionPhotos != null ? List<ReflectionPhoto>.unmodifiable(reflectionPhotos) : reflectionPhotos,
      questionnaireResponses: questionnaireResponses != null ? List<QuestionnaireResponse>.unmodifiable(questionnaireResponses) : questionnaireResponses,
      subscriptions: subscriptions != null ? List<UserSubscription>.unmodifiable(subscriptions) : subscriptions,
      actualCrystal: actualCrystal);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is User &&
      id == other.id &&
      _email == other._email &&
      _fullName == other._fullName &&
      _birthDate == other._birthDate &&
      _country == other._country &&
      _deviceOwnershipStatus == other._deviceOwnershipStatus &&
      _biometricsEnabled == other._biometricsEnabled &&
      _morningSacredRitualEnabled == other._morningSacredRitualEnabled &&
      _eveningReflectionAndBreath == other._eveningReflectionAndBreath &&
      _profileOwner == other._profileOwner &&
      DeepCollectionEquality().equals(_cycles, other._cycles) &&
      DeepCollectionEquality().equals(_dailyRituals, other._dailyRituals) &&
      DeepCollectionEquality().equals(_reflectionPhotos, other._reflectionPhotos) &&
      DeepCollectionEquality().equals(_questionnaireResponses, other._questionnaireResponses) &&
      DeepCollectionEquality().equals(_subscriptions, other._subscriptions) &&
      _actualCrystal == other._actualCrystal;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("User {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("email=" + "$_email" + ", ");
    buffer.write("fullName=" + "$_fullName" + ", ");
    buffer.write("birthDate=" + (_birthDate != null ? _birthDate!.format() : "null") + ", ");
    buffer.write("country=" + "$_country" + ", ");
    buffer.write("deviceOwnershipStatus=" + (_deviceOwnershipStatus != null ? amplify_core.enumToString(_deviceOwnershipStatus)! : "null") + ", ");
    buffer.write("biometricsEnabled=" + (_biometricsEnabled != null ? _biometricsEnabled!.toString() : "null") + ", ");
    buffer.write("morningSacredRitualEnabled=" + (_morningSacredRitualEnabled != null ? _morningSacredRitualEnabled!.toString() : "null") + ", ");
    buffer.write("eveningReflectionAndBreath=" + (_eveningReflectionAndBreath != null ? _eveningReflectionAndBreath!.toString() : "null") + ", ");
    buffer.write("profileOwner=" + "$_profileOwner" + ", ");
    buffer.write("actualCrystal=" + (_actualCrystal != null ? _actualCrystal!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  User copyWith({String? email, String? fullName, amplify_core.TemporalDate? birthDate, String? country, DeviceOwnershipStatus? deviceOwnershipStatus, bool? biometricsEnabled, bool? morningSacredRitualEnabled, bool? eveningReflectionAndBreath, String? profileOwner, List<User30DayCycle>? cycles, List<DailyRitual>? dailyRituals, List<ReflectionPhoto>? reflectionPhotos, List<QuestionnaireResponse>? questionnaireResponses, List<UserSubscription>? subscriptions, Crystal? actualCrystal}) {
    return User._internal(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      birthDate: birthDate ?? this.birthDate,
      country: country ?? this.country,
      deviceOwnershipStatus: deviceOwnershipStatus ?? this.deviceOwnershipStatus,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      morningSacredRitualEnabled: morningSacredRitualEnabled ?? this.morningSacredRitualEnabled,
      eveningReflectionAndBreath: eveningReflectionAndBreath ?? this.eveningReflectionAndBreath,
      profileOwner: profileOwner ?? this.profileOwner,
      cycles: cycles ?? this.cycles,
      dailyRituals: dailyRituals ?? this.dailyRituals,
      reflectionPhotos: reflectionPhotos ?? this.reflectionPhotos,
      questionnaireResponses: questionnaireResponses ?? this.questionnaireResponses,
      subscriptions: subscriptions ?? this.subscriptions,
      actualCrystal: actualCrystal ?? this.actualCrystal);
  }
  
  User copyWithModelFieldValues({
    ModelFieldValue<String>? email,
    ModelFieldValue<String>? fullName,
    ModelFieldValue<amplify_core.TemporalDate?>? birthDate,
    ModelFieldValue<String?>? country,
    ModelFieldValue<DeviceOwnershipStatus>? deviceOwnershipStatus,
    ModelFieldValue<bool>? biometricsEnabled,
    ModelFieldValue<bool>? morningSacredRitualEnabled,
    ModelFieldValue<bool>? eveningReflectionAndBreath,
    ModelFieldValue<String>? profileOwner,
    ModelFieldValue<List<User30DayCycle>?>? cycles,
    ModelFieldValue<List<DailyRitual>?>? dailyRituals,
    ModelFieldValue<List<ReflectionPhoto>?>? reflectionPhotos,
    ModelFieldValue<List<QuestionnaireResponse>?>? questionnaireResponses,
    ModelFieldValue<List<UserSubscription>?>? subscriptions,
    ModelFieldValue<Crystal?>? actualCrystal
  }) {
    return User._internal(
      id: id,
      email: email == null ? this.email : email.value,
      fullName: fullName == null ? this.fullName : fullName.value,
      birthDate: birthDate == null ? this.birthDate : birthDate.value,
      country: country == null ? this.country : country.value,
      deviceOwnershipStatus: deviceOwnershipStatus == null ? this.deviceOwnershipStatus : deviceOwnershipStatus.value,
      biometricsEnabled: biometricsEnabled == null ? this.biometricsEnabled : biometricsEnabled.value,
      morningSacredRitualEnabled: morningSacredRitualEnabled == null ? this.morningSacredRitualEnabled : morningSacredRitualEnabled.value,
      eveningReflectionAndBreath: eveningReflectionAndBreath == null ? this.eveningReflectionAndBreath : eveningReflectionAndBreath.value,
      profileOwner: profileOwner == null ? this.profileOwner : profileOwner.value,
      cycles: cycles == null ? this.cycles : cycles.value,
      dailyRituals: dailyRituals == null ? this.dailyRituals : dailyRituals.value,
      reflectionPhotos: reflectionPhotos == null ? this.reflectionPhotos : reflectionPhotos.value,
      questionnaireResponses: questionnaireResponses == null ? this.questionnaireResponses : questionnaireResponses.value,
      subscriptions: subscriptions == null ? this.subscriptions : subscriptions.value,
      actualCrystal: actualCrystal == null ? this.actualCrystal : actualCrystal.value
    );
  }
  
  User.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _email = json['email'],
      _fullName = json['fullName'],
      _birthDate = json['birthDate'] != null ? amplify_core.TemporalDate.fromString(json['birthDate']) : null,
      _country = json['country'],
      _deviceOwnershipStatus = amplify_core.enumFromString<DeviceOwnershipStatus>(json['deviceOwnershipStatus'], DeviceOwnershipStatus.values),
      _biometricsEnabled = json['biometricsEnabled'],
      _morningSacredRitualEnabled = json['morningSacredRitualEnabled'],
      _eveningReflectionAndBreath = json['eveningReflectionAndBreath'],
      _profileOwner = json['profileOwner'],
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
      _dailyRituals = json['dailyRituals']  is Map
        ? (json['dailyRituals']['items'] is List
          ? (json['dailyRituals']['items'] as List)
              .where((e) => e != null)
              .map((e) => DailyRitual.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['dailyRituals'] is List
          ? (json['dailyRituals'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => DailyRitual.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null),
      _reflectionPhotos = json['reflectionPhotos']  is Map
        ? (json['reflectionPhotos']['items'] is List
          ? (json['reflectionPhotos']['items'] as List)
              .where((e) => e != null)
              .map((e) => ReflectionPhoto.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['reflectionPhotos'] is List
          ? (json['reflectionPhotos'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => ReflectionPhoto.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null),
      _questionnaireResponses = json['questionnaireResponses']  is Map
        ? (json['questionnaireResponses']['items'] is List
          ? (json['questionnaireResponses']['items'] as List)
              .where((e) => e != null)
              .map((e) => QuestionnaireResponse.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['questionnaireResponses'] is List
          ? (json['questionnaireResponses'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => QuestionnaireResponse.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null),
      _subscriptions = json['subscriptions']  is Map
        ? (json['subscriptions']['items'] is List
          ? (json['subscriptions']['items'] as List)
              .where((e) => e != null)
              .map((e) => UserSubscription.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['subscriptions'] is List
          ? (json['subscriptions'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => UserSubscription.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null),
      _actualCrystal = json['actualCrystal'] != null
        ? json['actualCrystal']['serializedData'] != null
          ? Crystal.fromJson(new Map<String, dynamic>.from(json['actualCrystal']['serializedData']))
          : Crystal.fromJson(new Map<String, dynamic>.from(json['actualCrystal']))
        : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'email': _email, 'fullName': _fullName, 'birthDate': _birthDate?.format(), 'country': _country, 'deviceOwnershipStatus': amplify_core.enumToString(_deviceOwnershipStatus), 'biometricsEnabled': _biometricsEnabled, 'morningSacredRitualEnabled': _morningSacredRitualEnabled, 'eveningReflectionAndBreath': _eveningReflectionAndBreath, 'profileOwner': _profileOwner, 'cycles': _cycles?.map((User30DayCycle? e) => e?.toJson()).toList(), 'dailyRituals': _dailyRituals?.map((DailyRitual? e) => e?.toJson()).toList(), 'reflectionPhotos': _reflectionPhotos?.map((ReflectionPhoto? e) => e?.toJson()).toList(), 'questionnaireResponses': _questionnaireResponses?.map((QuestionnaireResponse? e) => e?.toJson()).toList(), 'subscriptions': _subscriptions?.map((UserSubscription? e) => e?.toJson()).toList(), 'actualCrystal': _actualCrystal?.toJson(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'email': _email,
    'fullName': _fullName,
    'birthDate': _birthDate,
    'country': _country,
    'deviceOwnershipStatus': _deviceOwnershipStatus,
    'biometricsEnabled': _biometricsEnabled,
    'morningSacredRitualEnabled': _morningSacredRitualEnabled,
    'eveningReflectionAndBreath': _eveningReflectionAndBreath,
    'profileOwner': _profileOwner,
    'cycles': _cycles,
    'dailyRituals': _dailyRituals,
    'reflectionPhotos': _reflectionPhotos,
    'questionnaireResponses': _questionnaireResponses,
    'subscriptions': _subscriptions,
    'actualCrystal': _actualCrystal,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<UserModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<UserModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final EMAIL = amplify_core.QueryField(fieldName: "email");
  static final FULLNAME = amplify_core.QueryField(fieldName: "fullName");
  static final BIRTHDATE = amplify_core.QueryField(fieldName: "birthDate");
  static final COUNTRY = amplify_core.QueryField(fieldName: "country");
  static final DEVICEOWNERSHIPSTATUS = amplify_core.QueryField(fieldName: "deviceOwnershipStatus");
  static final BIOMETRICSENABLED = amplify_core.QueryField(fieldName: "biometricsEnabled");
  static final MORNINGSACREDRITUALENABLED = amplify_core.QueryField(fieldName: "morningSacredRitualEnabled");
  static final EVENINGREFLECTIONANDBREATH = amplify_core.QueryField(fieldName: "eveningReflectionAndBreath");
  static final PROFILEOWNER = amplify_core.QueryField(fieldName: "profileOwner");
  static final CYCLES = amplify_core.QueryField(
    fieldName: "cycles",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'User30DayCycle'));
  static final DAILYRITUALS = amplify_core.QueryField(
    fieldName: "dailyRituals",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'DailyRitual'));
  static final REFLECTIONPHOTOS = amplify_core.QueryField(
    fieldName: "reflectionPhotos",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'ReflectionPhoto'));
  static final QUESTIONNAIRERESPONSES = amplify_core.QueryField(
    fieldName: "questionnaireResponses",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'QuestionnaireResponse'));
  static final SUBSCRIPTIONS = amplify_core.QueryField(
    fieldName: "subscriptions",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'UserSubscription'));
  static final ACTUALCRYSTAL = amplify_core.QueryField(
    fieldName: "actualCrystal",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'Crystal'));
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "User";
    modelSchemaDefinition.pluralName = "Users";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.OWNER,
        ownerField: "profileOwner",
        identityClaim: "cognito:username",
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.READ,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.GROUPS,
        groupClaim: "cognito:groups",
        groups: [ "Admins" ],
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["email"], name: "usersByEmail")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.EMAIL,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.FULLNAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.BIRTHDATE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.date)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.COUNTRY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.DEVICEOWNERSHIPSTATUS,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.BIOMETRICSENABLED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.MORNINGSACREDRITUALENABLED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.EVENINGREFLECTIONANDBREATH,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.PROFILEOWNER,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: User.CYCLES,
      isRequired: false,
      ofModelName: 'User30DayCycle',
      associatedKey: User30DayCycle.USER
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: User.DAILYRITUALS,
      isRequired: false,
      ofModelName: 'DailyRitual',
      associatedKey: DailyRitual.USER
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: User.REFLECTIONPHOTOS,
      isRequired: false,
      ofModelName: 'ReflectionPhoto',
      associatedKey: ReflectionPhoto.USER
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: User.QUESTIONNAIRERESPONSES,
      isRequired: false,
      ofModelName: 'QuestionnaireResponse',
      associatedKey: QuestionnaireResponse.USER
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: User.SUBSCRIPTIONS,
      isRequired: false,
      ofModelName: 'UserSubscription',
      associatedKey: UserSubscription.USER
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: User.ACTUALCRYSTAL,
      isRequired: false,
      targetNames: ['actualCrystalCode'],
      ofModelName: 'Crystal'
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

class _UserModelType extends amplify_core.ModelType<User> {
  const _UserModelType();
  
  @override
  User fromJson(Map<String, dynamic> jsonData) {
    return User.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'User';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [User] in your schema.
 */
class UserModelIdentifier implements amplify_core.ModelIdentifier<User> {
  final String id;

  /** Create an instance of UserModelIdentifier using [id] the primary key. */
  const UserModelIdentifier({
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
  String toString() => 'UserModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is UserModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}