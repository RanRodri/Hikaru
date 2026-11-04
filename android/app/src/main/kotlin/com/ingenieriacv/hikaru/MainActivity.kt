package com.ingenieriacv.hikaru

import io.flutter.embedding.android.FlutterFragmentActivity

// local_auth shows the system fingerprint / face prompt as a fragment, so it
// needs a FragmentActivity. With a plain FlutterActivity every authenticate()
// call fails and the sensor never appears.
class MainActivity : FlutterFragmentActivity()
