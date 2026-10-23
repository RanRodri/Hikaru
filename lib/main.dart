import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'amplify_outputs.dart';
import 'app.dart';
import 'models/ModelProvider.dart' as amplify_models;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  // Portrait everywhere. Only the cymatic projection unlocks landscape.
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);
  runApp(const ProviderScope(child: HikaruApp()));
}

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugins([
      AmplifyAuthCognito(),
      AmplifyAPI(
        options: APIPluginOptions(
          modelProvider: amplify_models.ModelProvider.instance,
        ),
      ),
      AmplifyStorageS3(),
    ]);
    await Amplify.configure(amplifyConfig);
  } on AmplifyAlreadyConfiguredException {
    // A hot restart configures Amplify a second time.
  }
}
