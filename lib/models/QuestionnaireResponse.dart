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


/** This is an auto generated class representing the QuestionnaireResponse type in your schema. */
class QuestionnaireResponse extends amplify_core.Model {
  static const classType = const _QuestionnaireResponseModelType();
  final String id;
  final User? _user;
  final QuestionOption? _questionOption;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  QuestionnaireResponseModelIdentifier get modelIdentifier {
      return QuestionnaireResponseModelIdentifier(
        id: id
      );
  }
  
  User? get user {
    return _user;
  }
  
  QuestionOption? get questionOption {
    return _questionOption;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const QuestionnaireResponse._internal({required this.id, user, questionOption, createdAt, updatedAt}): _user = user, _questionOption = questionOption, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory QuestionnaireResponse({String? id, User? user, QuestionOption? questionOption}) {
    return QuestionnaireResponse._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      user: user,
      questionOption: questionOption);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is QuestionnaireResponse &&
      id == other.id &&
      _user == other._user &&
      _questionOption == other._questionOption;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("QuestionnaireResponse {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("user=" + (_user != null ? _user!.toString() : "null") + ", ");
    buffer.write("questionOption=" + (_questionOption != null ? _questionOption!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  QuestionnaireResponse copyWith({User? user, QuestionOption? questionOption}) {
    return QuestionnaireResponse._internal(
      id: id,
      user: user ?? this.user,
      questionOption: questionOption ?? this.questionOption);
  }
  
  QuestionnaireResponse copyWithModelFieldValues({
    ModelFieldValue<User?>? user,
    ModelFieldValue<QuestionOption?>? questionOption
  }) {
    return QuestionnaireResponse._internal(
      id: id,
      user: user == null ? this.user : user.value,
      questionOption: questionOption == null ? this.questionOption : questionOption.value
    );
  }
  
  QuestionnaireResponse.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _user = json['user'] != null
        ? json['user']['serializedData'] != null
          ? User.fromJson(new Map<String, dynamic>.from(json['user']['serializedData']))
          : User.fromJson(new Map<String, dynamic>.from(json['user']))
        : null,
      _questionOption = json['questionOption'] != null
        ? json['questionOption']['serializedData'] != null
          ? QuestionOption.fromJson(new Map<String, dynamic>.from(json['questionOption']['serializedData']))
          : QuestionOption.fromJson(new Map<String, dynamic>.from(json['questionOption']))
        : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'user': _user?.toJson(), 'questionOption': _questionOption?.toJson(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'user': _user,
    'questionOption': _questionOption,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<QuestionnaireResponseModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<QuestionnaireResponseModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USER = amplify_core.QueryField(
    fieldName: "user",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'User'));
  static final QUESTIONOPTION = amplify_core.QueryField(
    fieldName: "questionOption",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'QuestionOption'));
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "QuestionnaireResponse";
    modelSchemaDefinition.pluralName = "QuestionnaireResponses";
    
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
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: QuestionnaireResponse.USER,
      isRequired: false,
      targetNames: ['userId'],
      ofModelName: 'User'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: QuestionnaireResponse.QUESTIONOPTION,
      isRequired: false,
      targetNames: ['questionOptionId'],
      ofModelName: 'QuestionOption'
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

class _QuestionnaireResponseModelType extends amplify_core.ModelType<QuestionnaireResponse> {
  const _QuestionnaireResponseModelType();
  
  @override
  QuestionnaireResponse fromJson(Map<String, dynamic> jsonData) {
    return QuestionnaireResponse.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'QuestionnaireResponse';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [QuestionnaireResponse] in your schema.
 */
class QuestionnaireResponseModelIdentifier implements amplify_core.ModelIdentifier<QuestionnaireResponse> {
  final String id;

  /** Create an instance of QuestionnaireResponseModelIdentifier using [id] the primary key. */
  const QuestionnaireResponseModelIdentifier({
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
  String toString() => 'QuestionnaireResponseModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is QuestionnaireResponseModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}