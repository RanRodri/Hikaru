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


/** This is an auto generated class representing the QuestionOption type in your schema. */
class QuestionOption extends amplify_core.Model {
  static const classType = const _QuestionOptionModelType();
  final String id;
  final String? _text;
  final int? _sortOrder;
  final Question? _question;
  final List<QuestionnaireResponse>? _questionnaireResponses;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  QuestionOptionModelIdentifier get modelIdentifier {
      return QuestionOptionModelIdentifier(
        id: id
      );
  }
  
  String get text {
    try {
      return _text!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int? get sortOrder {
    return _sortOrder;
  }
  
  Question? get question {
    return _question;
  }
  
  List<QuestionnaireResponse>? get questionnaireResponses {
    return _questionnaireResponses;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const QuestionOption._internal({required this.id, required text, sortOrder, question, questionnaireResponses, createdAt, updatedAt}): _text = text, _sortOrder = sortOrder, _question = question, _questionnaireResponses = questionnaireResponses, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory QuestionOption({String? id, required String text, int? sortOrder, Question? question, List<QuestionnaireResponse>? questionnaireResponses}) {
    return QuestionOption._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      text: text,
      sortOrder: sortOrder,
      question: question,
      questionnaireResponses: questionnaireResponses != null ? List<QuestionnaireResponse>.unmodifiable(questionnaireResponses) : questionnaireResponses);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is QuestionOption &&
      id == other.id &&
      _text == other._text &&
      _sortOrder == other._sortOrder &&
      _question == other._question &&
      DeepCollectionEquality().equals(_questionnaireResponses, other._questionnaireResponses);
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("QuestionOption {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("text=" + "$_text" + ", ");
    buffer.write("sortOrder=" + (_sortOrder != null ? _sortOrder!.toString() : "null") + ", ");
    buffer.write("question=" + (_question != null ? _question!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  QuestionOption copyWith({String? text, int? sortOrder, Question? question, List<QuestionnaireResponse>? questionnaireResponses}) {
    return QuestionOption._internal(
      id: id,
      text: text ?? this.text,
      sortOrder: sortOrder ?? this.sortOrder,
      question: question ?? this.question,
      questionnaireResponses: questionnaireResponses ?? this.questionnaireResponses);
  }
  
  QuestionOption copyWithModelFieldValues({
    ModelFieldValue<String>? text,
    ModelFieldValue<int?>? sortOrder,
    ModelFieldValue<Question?>? question,
    ModelFieldValue<List<QuestionnaireResponse>?>? questionnaireResponses
  }) {
    return QuestionOption._internal(
      id: id,
      text: text == null ? this.text : text.value,
      sortOrder: sortOrder == null ? this.sortOrder : sortOrder.value,
      question: question == null ? this.question : question.value,
      questionnaireResponses: questionnaireResponses == null ? this.questionnaireResponses : questionnaireResponses.value
    );
  }
  
  QuestionOption.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _text = json['text'],
      _sortOrder = (json['sortOrder'] as num?)?.toInt(),
      _question = json['question'] != null
        ? json['question']['serializedData'] != null
          ? Question.fromJson(new Map<String, dynamic>.from(json['question']['serializedData']))
          : Question.fromJson(new Map<String, dynamic>.from(json['question']))
        : null,
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
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'text': _text, 'sortOrder': _sortOrder, 'question': _question?.toJson(), 'questionnaireResponses': _questionnaireResponses?.map((QuestionnaireResponse? e) => e?.toJson()).toList(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'text': _text,
    'sortOrder': _sortOrder,
    'question': _question,
    'questionnaireResponses': _questionnaireResponses,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<QuestionOptionModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<QuestionOptionModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final TEXT = amplify_core.QueryField(fieldName: "text");
  static final SORTORDER = amplify_core.QueryField(fieldName: "sortOrder");
  static final QUESTION = amplify_core.QueryField(
    fieldName: "question",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'Question'));
  static final QUESTIONNAIRERESPONSES = amplify_core.QueryField(
    fieldName: "questionnaireResponses",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'QuestionnaireResponse'));
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "QuestionOption";
    modelSchemaDefinition.pluralName = "QuestionOptions";
    
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
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: QuestionOption.TEXT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: QuestionOption.SORTORDER,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: QuestionOption.QUESTION,
      isRequired: false,
      targetNames: ['questionId'],
      ofModelName: 'Question'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: QuestionOption.QUESTIONNAIRERESPONSES,
      isRequired: false,
      ofModelName: 'QuestionnaireResponse',
      associatedKey: QuestionnaireResponse.QUESTIONOPTION
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

class _QuestionOptionModelType extends amplify_core.ModelType<QuestionOption> {
  const _QuestionOptionModelType();
  
  @override
  QuestionOption fromJson(Map<String, dynamic> jsonData) {
    return QuestionOption.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'QuestionOption';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [QuestionOption] in your schema.
 */
class QuestionOptionModelIdentifier implements amplify_core.ModelIdentifier<QuestionOption> {
  final String id;

  /** Create an instance of QuestionOptionModelIdentifier using [id] the primary key. */
  const QuestionOptionModelIdentifier({
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
  String toString() => 'QuestionOptionModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is QuestionOptionModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}