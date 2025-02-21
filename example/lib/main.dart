import 'package:flutter/material.dart';
import 'package:livekit_example/theme.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'pages/connect.dart';

dynamic toIntIfInt(dynamic v) {
  return v != null
      ? int.tryParse(v) != null
          ? int.parse(v)
          : v
      : null;
}

void main() async {
  // final format = DateFormat('HH:mm:ss');
  // // configure logs for debugging
  // Logger.root.level = Level.FINE;
  // Logger.root.onRecord.listen((record) {
  //   print('${format.format(record.time)}: ${record.message}');
  // });

  toIntIfInt('- ');

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const LiveKitExampleApp());
}

class LiveKitExampleApp extends StatelessWidget {
  //
  const LiveKitExampleApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'LiveKit Flutter Example',
        theme: LiveKitTheme().buildThemeData(context),
        home: const ConnectPage(),
      );
}
