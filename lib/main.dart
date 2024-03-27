import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:task_manager/base/dependency/app_service.dart';
import 'package:task_manager/base/dependency/local_storage/local_storage_service.dart';
import 'package:task_manager/base/dependency/router/utils/route_name.dart';
import 'package:task_manager/base/dependency/router/utils/route_page.dart';
import 'package:task_manager/constants/colors.dart';
import 'package:task_manager/firebase_options.dart';
import 'package:task_manager/shared/theme/main.dart';
import 'package:task_manager/shared/utilities/fcm.dart';

Future<void> initDependencies() async {
  await dotenv.load(fileName: ".env");
  await initHiveForFlutter();
  final localStorage = LocalStorageService();
  await localStorage.initialize();
  AppService.localStorage = Provider((ref) => localStorage);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessagingUtils.requestPermission();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is Trace) return stack.vmTrace;
    if (stack is Chain) return stack.toTrace().vmTrace;
    return stack;
  };
  await initDependencies();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, ref) {
    final routerService = ref.watch(AppService.router);
    final graphQLService = ref.watch(AppService.graphQL);
    final toastService = ref.watch(AppService.toast);
    final materialApp = MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme.copyWith(
        pageTransitionsTheme: AppTheme.pageTransitionsTheme,
      ),
      navigatorObservers: [toastService.observer],
      builder: toastService.init(),
      onGenerateRoute: RoutePage.onGenerateRoute,
      navigatorKey: routerService.navigatorKey,
      initialRoute: RouteName.login,
      color: ColorConstants.primary,
    );
    return GraphQLProvider(
      client: graphQLService.clientValueNotifier,
      child: materialApp,
    );
  }
}
