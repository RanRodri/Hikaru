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


/** This is an auto generated class representing the User30DayCycle type in your schema. */
class User30DayCycle extends amplify_core.Model {
  static const classType = const _User30DayCycleModelType();
  final String id;
  final amplify_core.TemporalDate? _startDate;
  final amplify_core.TemporalDate? _endDate;
  final int? _currentDay;
  final bool? _isActive;
  final int? _streak;
  final User? _user;
  final Crystal? _crystal;
  final List<DailyRitual>? _dailyRituals;
  final List<ReflectionPhoto>? _reflectionPhotos;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  User30DayCycleModelIdentifier get modelIdentifier {
      return User30DayCycleModelIdentifier(
        id: id
      );
  }
  
  amplify_core.TemporalDate get startDate {
    try {
      return _startDate!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDate get endDate {
    try {
      return _endDate!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get currentDay {
    try {
      return _currentDay!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  bool get isActive {
    try {
      return _isActive!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get streak {
    try {
      return _streak!;
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
  
  Crystal? get crystal {
    return _crystal;
  }
  
  List<DailyRitual>? get dailyRituals {
    return _dailyRituals;
  }
  
  List<ReflectionPhoto>? get reflectionPhotos {
    return _reflectionPhotos;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const User30DayCycle._internal({required this.id, required startDate, required endDate, required currentDay, required isActive, required streak, user, crystal, dailyRituals, reflectionPhotos, createdAt, updatedAt}): _startDate = startDate, _endDate = endDate, _currentDay = currentDay, _isActive = isActive, _streak = streak, _user = user, _crystal = crystal, _dailyRituals = dailyRituals, _reflectionPhotos = reflectionPhotos, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory User30DayCycle({String? id, required amplify_core.TemporalDate startDate, required amplify_core.TemporalDate endDate, required int currentDay, required bool isActive, required int streak, User? user, Crystal? crystal, List<DailyRitual>? dailyRituals, List<ReflectionPhoto>? reflectionPhotos}) {
    return User30DayCycle._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      startDate: startDate,
      endDate: endDate,
      currentDay: currentDay,
      isActive: isActive,
      streak: streak,
      user: user,
      crystal: crystal,
      dailyRituals: dailyRituals != null ? List<DailyRitual>.unmodifiable(dailyRituals) : dailyRituals,
      reflectionPhotos: reflectionPhotos != null ? List<ReflectionPhoto>.unmodifiable(reflectionPhotos) : reflectionPhotos);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is User30DayCycle &&
      id == other.id &&
      _startDate == other._startDate &&
      _endDate == other._endDate &&
      _currentDay == other._currentDay &&
      _isActive == other._isActive &&
      _streak == other._streak &&
      _user == other._user &&
      _crystal == other._crystal &&
      DeepCollectionEquality().equals(_dailyRituals, other._dailyRituals) &&
      DeepCollectionEquality().equals(_reflectionPhotos, other._reflectionPhotos);
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("User30DayCycle {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("startDate=" + (_startDate != null ? _startDate!.format() : "null") + ", ");
    buffer.write("endDate=" + (_endDate != null ? _endDate!.format() : "null") + ", ");
    buffer.write("currentDay=" + (_currentDay != null ? _currentDay!.toString() : "null") + ", ");
    buffer.write("isActive=" + (_isActive != null ? _isActive!.toString() : "null") + ", ");
    buffer.write("streak=" + (_streak != null ? _streak!.toString() : "null") + ", ");
    buffer.write("user=" + (_user != null ? _user!.toString() : "null") + ", ");
    buffer.write("crystal=" + (_crystal != null ? _crystal!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  User30DayCycle copyWith({amplify_core.TemporalDate? startDate, amplify_core.TemporalDate? endDate, int? currentDay, bool? isActive, int? streak, User? user, Crystal? crystal, List<DailyRitual>? dailyRituals, List<ReflectionPhoto>? reflectionPhotos}) {
    return User30DayCycle._internal(
      id: id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      currentDay: currentDay ?? this.currentDay,
      isActive: isActive ?? this.isActive,
      streak: streak ?? this.streak,
      user: user ?? this.user,
      crystal: crystal ?? this.crystal,
      dailyRituals: dailyRituals ?? this.dailyRituals,
      reflectionPhotos: reflectionPhotos ?? this.reflectionPhotos);
  }
  
  User30DayCycle copyWithModelFieldValues({
    ModelFieldValue<amplify_core.TemporalDate>? startDate,
    ModelFieldValue<amplify_core.TemporalDate>? endDate,
    ModelFieldValue<int>? currentDay,
    ModelFieldValue<bool>? isActive,
    ModelFieldValue<int>? streak,
    ModelFieldValue<User?>? user,
    ModelFieldValue<Crystal?>? crystal,
    ModelFieldValue<List<DailyRitual>?>? dailyRituals,
    ModelFieldValue<List<ReflectionPhoto>?>? reflectionPhotos
  }) {
    return User30DayCycle._internal(
      id: id,
      startDate: startDate == null ? this.startDate : startDate.value,
      endDate: endDate == null ? this.endDate : endDate.value,
      currentDay: currentDay == null ? this.currentDay : currentDay.value,
      isActive: isActive == null ? this.isActive : isActive.value,
      streak: streak == null ? this.streak : streak.value,
      user: user == null ? this.user : user.value,
      crystal: crystal == null ? this.crystal : crystal.value,
      dailyRituals: dailyRituals == null ? this.dailyRituals : dailyRituals.value,
      reflectionPhotos: reflectionPhotos == null ? this.reflectionPhotos : reflectionPhotos.value
    );
  }
  
  User30DayCycle.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _startDate = json['startDate'] != null ? amplify_core.TemporalDate.fromString(json['startDate']) : null,
      _endDate = json['endDate'] != null ? amplify_core.TemporalDate.fromString(json['endDate']) : null,
      _currentDay = (json['currentDay'] as num?)?.toInt(),
      _isActive = json['isActive'],
      _streak = (json['streak'] as num?)?.toInt(),
      _user = json['user'] != null
        ? json['user']['serializedData'] != null
          ? User.fromJson(new Map<String, dynamic>.from(json['user']['serializedData']))
          : User.fromJson(new Map<String, dynamic>.from(json['user']))
        : null,
      _crystal = json['crystal'] != null
        ? json['crystal']['serializedData'] != null
          ? Crystal.fromJson(new Map<String, dynamic>.from(json['crystal']['serializedData']))
          : Crystal.fromJson(new Map<String, dynamic>.from(json['crystal']))
        : null,
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
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'startDate': _startDate?.format(), 'endDate': _endDate?.format(), 'currentDay': _currentDay, 'isActive': _isActive, 'streak': _streak, 'user': _user?.toJson(), 'crystal': _crystal?.toJson(), 'dailyRituals': _dailyRituals?.map((DailyRitual? e) => e?.toJson()).toList(), 'reflectionPhotos': _reflectionPhotos?.map((ReflectionPhoto? e) => e?.toJson()).toList(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'startDate': _startDate,
    'endDate': _endDate,
    'currentDay': _currentDay,
    'isActive': _isActive,
    'streak': _streak,
    'user': _user,
    'crystal': _crystal,
    'dailyRituals': _dailyRituals,
    'reflectionPhotos': _reflectionPhotos,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<User30DayCycleModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<User30DayCycleModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final STARTDATE = amplify_core.QueryField(fieldName: "startDate");
  static final ENDDATE = amplify_core.QueryField(fieldName: "endDate");
  static final CURRENTDAY = amplify_core.QueryField(fieldName: "currentDay");
  static final ISACTIVE = amplify_core.QueryField(fieldName: "isActive");
  static final STREAK = amplify_core.QueryField(fieldName: "streak");
  static final USER = amplify_core.QueryField(
    fieldName: "user",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'User'));
  static final CRYSTAL = amplify_core.QueryField(
    fieldName: "crystal",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'Crystal'));
  static final DAILYRITUALS = amplify_core.QueryField(
    fieldName: "dailyRituals",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'DailyRitual'));
  static final REFLECTIONPHOTOS = amplify_core.QueryField(
    fieldName: "reflectionPhotos",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'ReflectionPhoto'));
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "User30DayCycle";
    modelSchemaDefinition.pluralName = "User30DayCycles";
    
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
      key: User30DayCycle.STARTDATE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.date)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User30DayCycle.ENDDATE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.date)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User30DayCycle.CURRENTDAY,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User30DayCycle.ISACTIVE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User30DayCycle.STREAK,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: User30DayCycle.USER,
      isRequired: false,
      targetNames: ['userId'],
      ofModelName: 'User'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: User30DayCycle.CRYSTAL,
      isRequired: false,
      targetNames: ['crystalCode'],
      ofModelName: 'Crystal'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: User30DayCycle.DAILYRITUALS,
      isRequired: false,
      ofModelName: 'DailyRitual',
      associatedKey: DailyRitual.CYCLE
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: User30DayCycle.REFLECTIONPHOTOS,
      isRequired: false,
      ofModelName: 'ReflectionPhoto',
      associatedKey: ReflectionPhoto.CYCLE
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

class _User30DayCycleModelType extends amplify_core.ModelType<User30DayCycle> {
  const _User30DayCycleModelType();
  
  @override
  User30DayCycle fromJson(Map<String, dynamic> jsonData) {
    return User30DayCycle.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'User30DayCycle';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [User30DayCycle] in your schema.
 */
class User30DayCycleModelIdentifier implements amplify_core.ModelIdentifier<User30DayCycle> {
  final String id;

  /** Create an instance of User30DayCycleModelIdentifier using [id] the primary key. */
  const User30DayCycleModelIdentifier({
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
  String toString() => 'User30DayCycleModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is User30DayCycleModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}