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


/** This is an auto generated class representing the DailyRitual type in your schema. */
class DailyRitual extends amplify_core.Model {
  static const classType = const _DailyRitualModelType();
  final String id;
  final int? _dayNumber;
  final amplify_core.TemporalDate? _date;
  final Element? _element;
  final String? _threeWordIntention;
  final bool? _isMerkabahDone;
  final bool? _isMassageDone;
  final bool? _isFrequencyUnlocked;
  final bool? _isFrequencyDone;
  final bool? _isCompleted;
  final int? _ratingStars;
  final List<String>? _feedbackTags;
  final User? _user;
  final User30DayCycle? _cycle;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  DailyRitualModelIdentifier get modelIdentifier {
      return DailyRitualModelIdentifier(
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
  
  amplify_core.TemporalDate get date {
    try {
      return _date!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  Element? get element {
    return _element;
  }
  
  String? get threeWordIntention {
    return _threeWordIntention;
  }
  
  bool get isMerkabahDone {
    try {
      return _isMerkabahDone!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  bool get isMassageDone {
    try {
      return _isMassageDone!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  bool get isFrequencyUnlocked {
    try {
      return _isFrequencyUnlocked!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  bool get isFrequencyDone {
    try {
      return _isFrequencyDone!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  bool get isCompleted {
    try {
      return _isCompleted!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int? get ratingStars {
    return _ratingStars;
  }
  
  List<String>? get feedbackTags {
    return _feedbackTags;
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
  
  const DailyRitual._internal({required this.id, required dayNumber, required date, element, threeWordIntention, required isMerkabahDone, required isMassageDone, required isFrequencyUnlocked, required isFrequencyDone, required isCompleted, ratingStars, feedbackTags, user, cycle, createdAt, updatedAt}): _dayNumber = dayNumber, _date = date, _element = element, _threeWordIntention = threeWordIntention, _isMerkabahDone = isMerkabahDone, _isMassageDone = isMassageDone, _isFrequencyUnlocked = isFrequencyUnlocked, _isFrequencyDone = isFrequencyDone, _isCompleted = isCompleted, _ratingStars = ratingStars, _feedbackTags = feedbackTags, _user = user, _cycle = cycle, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory DailyRitual({String? id, required int dayNumber, required amplify_core.TemporalDate date, Element? element, String? threeWordIntention, required bool isMerkabahDone, required bool isMassageDone, required bool isFrequencyUnlocked, required bool isFrequencyDone, required bool isCompleted, int? ratingStars, List<String>? feedbackTags, User? user, User30DayCycle? cycle}) {
    return DailyRitual._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      dayNumber: dayNumber,
      date: date,
      element: element,
      threeWordIntention: threeWordIntention,
      isMerkabahDone: isMerkabahDone,
      isMassageDone: isMassageDone,
      isFrequencyUnlocked: isFrequencyUnlocked,
      isFrequencyDone: isFrequencyDone,
      isCompleted: isCompleted,
      ratingStars: ratingStars,
      feedbackTags: feedbackTags != null ? List<String>.unmodifiable(feedbackTags) : feedbackTags,
      user: user,
      cycle: cycle);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DailyRitual &&
      id == other.id &&
      _dayNumber == other._dayNumber &&
      _date == other._date &&
      _element == other._element &&
      _threeWordIntention == other._threeWordIntention &&
      _isMerkabahDone == other._isMerkabahDone &&
      _isMassageDone == other._isMassageDone &&
      _isFrequencyUnlocked == other._isFrequencyUnlocked &&
      _isFrequencyDone == other._isFrequencyDone &&
      _isCompleted == other._isCompleted &&
      _ratingStars == other._ratingStars &&
      DeepCollectionEquality().equals(_feedbackTags, other._feedbackTags) &&
      _user == other._user &&
      _cycle == other._cycle;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("DailyRitual {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("dayNumber=" + (_dayNumber != null ? _dayNumber!.toString() : "null") + ", ");
    buffer.write("date=" + (_date != null ? _date!.format() : "null") + ", ");
    buffer.write("element=" + (_element != null ? amplify_core.enumToString(_element)! : "null") + ", ");
    buffer.write("threeWordIntention=" + "$_threeWordIntention" + ", ");
    buffer.write("isMerkabahDone=" + (_isMerkabahDone != null ? _isMerkabahDone!.toString() : "null") + ", ");
    buffer.write("isMassageDone=" + (_isMassageDone != null ? _isMassageDone!.toString() : "null") + ", ");
    buffer.write("isFrequencyUnlocked=" + (_isFrequencyUnlocked != null ? _isFrequencyUnlocked!.toString() : "null") + ", ");
    buffer.write("isFrequencyDone=" + (_isFrequencyDone != null ? _isFrequencyDone!.toString() : "null") + ", ");
    buffer.write("isCompleted=" + (_isCompleted != null ? _isCompleted!.toString() : "null") + ", ");
    buffer.write("ratingStars=" + (_ratingStars != null ? _ratingStars!.toString() : "null") + ", ");
    buffer.write("feedbackTags=" + (_feedbackTags != null ? _feedbackTags!.toString() : "null") + ", ");
    buffer.write("user=" + (_user != null ? _user!.toString() : "null") + ", ");
    buffer.write("cycle=" + (_cycle != null ? _cycle!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  DailyRitual copyWith({int? dayNumber, amplify_core.TemporalDate? date, Element? element, String? threeWordIntention, bool? isMerkabahDone, bool? isMassageDone, bool? isFrequencyUnlocked, bool? isFrequencyDone, bool? isCompleted, int? ratingStars, List<String>? feedbackTags, User? user, User30DayCycle? cycle}) {
    return DailyRitual._internal(
      id: id,
      dayNumber: dayNumber ?? this.dayNumber,
      date: date ?? this.date,
      element: element ?? this.element,
      threeWordIntention: threeWordIntention ?? this.threeWordIntention,
      isMerkabahDone: isMerkabahDone ?? this.isMerkabahDone,
      isMassageDone: isMassageDone ?? this.isMassageDone,
      isFrequencyUnlocked: isFrequencyUnlocked ?? this.isFrequencyUnlocked,
      isFrequencyDone: isFrequencyDone ?? this.isFrequencyDone,
      isCompleted: isCompleted ?? this.isCompleted,
      ratingStars: ratingStars ?? this.ratingStars,
      feedbackTags: feedbackTags ?? this.feedbackTags,
      user: user ?? this.user,
      cycle: cycle ?? this.cycle);
  }
  
  DailyRitual copyWithModelFieldValues({
    ModelFieldValue<int>? dayNumber,
    ModelFieldValue<amplify_core.TemporalDate>? date,
    ModelFieldValue<Element?>? element,
    ModelFieldValue<String?>? threeWordIntention,
    ModelFieldValue<bool>? isMerkabahDone,
    ModelFieldValue<bool>? isMassageDone,
    ModelFieldValue<bool>? isFrequencyUnlocked,
    ModelFieldValue<bool>? isFrequencyDone,
    ModelFieldValue<bool>? isCompleted,
    ModelFieldValue<int?>? ratingStars,
    ModelFieldValue<List<String>?>? feedbackTags,
    ModelFieldValue<User?>? user,
    ModelFieldValue<User30DayCycle?>? cycle
  }) {
    return DailyRitual._internal(
      id: id,
      dayNumber: dayNumber == null ? this.dayNumber : dayNumber.value,
      date: date == null ? this.date : date.value,
      element: element == null ? this.element : element.value,
      threeWordIntention: threeWordIntention == null ? this.threeWordIntention : threeWordIntention.value,
      isMerkabahDone: isMerkabahDone == null ? this.isMerkabahDone : isMerkabahDone.value,
      isMassageDone: isMassageDone == null ? this.isMassageDone : isMassageDone.value,
      isFrequencyUnlocked: isFrequencyUnlocked == null ? this.isFrequencyUnlocked : isFrequencyUnlocked.value,
      isFrequencyDone: isFrequencyDone == null ? this.isFrequencyDone : isFrequencyDone.value,
      isCompleted: isCompleted == null ? this.isCompleted : isCompleted.value,
      ratingStars: ratingStars == null ? this.ratingStars : ratingStars.value,
      feedbackTags: feedbackTags == null ? this.feedbackTags : feedbackTags.value,
      user: user == null ? this.user : user.value,
      cycle: cycle == null ? this.cycle : cycle.value
    );
  }
  
  DailyRitual.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _dayNumber = (json['dayNumber'] as num?)?.toInt(),
      _date = json['date'] != null ? amplify_core.TemporalDate.fromString(json['date']) : null,
      _element = amplify_core.enumFromString<Element>(json['element'], Element.values),
      _threeWordIntention = json['threeWordIntention'],
      _isMerkabahDone = json['isMerkabahDone'],
      _isMassageDone = json['isMassageDone'],
      _isFrequencyUnlocked = json['isFrequencyUnlocked'],
      _isFrequencyDone = json['isFrequencyDone'],
      _isCompleted = json['isCompleted'],
      _ratingStars = (json['ratingStars'] as num?)?.toInt(),
      _feedbackTags = json['feedbackTags']?.cast<String>(),
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
    'id': id, 'dayNumber': _dayNumber, 'date': _date?.format(), 'element': amplify_core.enumToString(_element), 'threeWordIntention': _threeWordIntention, 'isMerkabahDone': _isMerkabahDone, 'isMassageDone': _isMassageDone, 'isFrequencyUnlocked': _isFrequencyUnlocked, 'isFrequencyDone': _isFrequencyDone, 'isCompleted': _isCompleted, 'ratingStars': _ratingStars, 'feedbackTags': _feedbackTags, 'user': _user?.toJson(), 'cycle': _cycle?.toJson(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'dayNumber': _dayNumber,
    'date': _date,
    'element': _element,
    'threeWordIntention': _threeWordIntention,
    'isMerkabahDone': _isMerkabahDone,
    'isMassageDone': _isMassageDone,
    'isFrequencyUnlocked': _isFrequencyUnlocked,
    'isFrequencyDone': _isFrequencyDone,
    'isCompleted': _isCompleted,
    'ratingStars': _ratingStars,
    'feedbackTags': _feedbackTags,
    'user': _user,
    'cycle': _cycle,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<DailyRitualModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<DailyRitualModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final DAYNUMBER = amplify_core.QueryField(fieldName: "dayNumber");
  static final DATE = amplify_core.QueryField(fieldName: "date");
  static final ELEMENT = amplify_core.QueryField(fieldName: "element");
  static final THREEWORDINTENTION = amplify_core.QueryField(fieldName: "threeWordIntention");
  static final ISMERKABAHDONE = amplify_core.QueryField(fieldName: "isMerkabahDone");
  static final ISMASSAGEDONE = amplify_core.QueryField(fieldName: "isMassageDone");
  static final ISFREQUENCYUNLOCKED = amplify_core.QueryField(fieldName: "isFrequencyUnlocked");
  static final ISFREQUENCYDONE = amplify_core.QueryField(fieldName: "isFrequencyDone");
  static final ISCOMPLETED = amplify_core.QueryField(fieldName: "isCompleted");
  static final RATINGSTARS = amplify_core.QueryField(fieldName: "ratingStars");
  static final FEEDBACKTAGS = amplify_core.QueryField(fieldName: "feedbackTags");
  static final USER = amplify_core.QueryField(
    fieldName: "user",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'User'));
  static final CYCLE = amplify_core.QueryField(
    fieldName: "cycle",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'User30DayCycle'));
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "DailyRitual";
    modelSchemaDefinition.pluralName = "DailyRituals";
    
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
      key: DailyRitual.DAYNUMBER,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DailyRitual.DATE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.date)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DailyRitual.ELEMENT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DailyRitual.THREEWORDINTENTION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DailyRitual.ISMERKABAHDONE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DailyRitual.ISMASSAGEDONE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DailyRitual.ISFREQUENCYUNLOCKED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DailyRitual.ISFREQUENCYDONE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DailyRitual.ISCOMPLETED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DailyRitual.RATINGSTARS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DailyRitual.FEEDBACKTAGS,
      isRequired: false,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: DailyRitual.USER,
      isRequired: false,
      targetNames: ['userId'],
      ofModelName: 'User'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: DailyRitual.CYCLE,
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

class _DailyRitualModelType extends amplify_core.ModelType<DailyRitual> {
  const _DailyRitualModelType();
  
  @override
  DailyRitual fromJson(Map<String, dynamic> jsonData) {
    return DailyRitual.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'DailyRitual';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [DailyRitual] in your schema.
 */
class DailyRitualModelIdentifier implements amplify_core.ModelIdentifier<DailyRitual> {
  final String id;

  /** Create an instance of DailyRitualModelIdentifier using [id] the primary key. */
  const DailyRitualModelIdentifier({
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
  String toString() => 'DailyRitualModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is DailyRitualModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}