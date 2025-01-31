import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
//import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_api/amplify_api.dart'; // UNCOMMENT this line after backend is deployed

// Generated in previous step
import 'models/ModelProvider.dart';
import 'amplifyconfiguration.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  PRESDB? foundPRESDB;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      await Amplify.addPlugins([
        AmplifyAPI(
            options: APIPluginOptions(modelProvider: ModelProvider.instance)),
      ]);
      await Amplify.configure(amplifyconfig);
      safePrint('Successfully configured Amplify');
    } on AmplifyException catch (e) {
      safePrint('Could not configure Amplify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('PRESDB Test'),
              ElevatedButton(
                onPressed: () {
                  createPRESDB();
                },
                child: const Text('Create generic'),
              ),
              ElevatedButton(
                onPressed: () {
                  createPRESDB('History', '{"History" = []}');
                },
                child: const Text('Create History'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final List<PRESDB?> items = await queryListItems();
                  safePrint(items
                      .map((item) => 'ID: ${item?.id}, Value: ${item?.value}')
                      .join('\n'));
                },
                child: const Text('List'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final PRESDB? item = await getPRESDBById('History');
                  safePrint('Found Item: $item');
                  setState(() {
                    foundPRESDB = item;
                  });
                },
                child: const Text('Find'),
              ),
              ElevatedButton(
                onPressed: foundPRESDB == null
                    ? null
                    : () {
                        updatePRESDB(foundPRESDB!);
                      },
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createPRESDB([String? id, String? val]) async {
    PRESDB model;
    try {
      if (id == null) {
        model = PRESDB(value: "Lorem ipsum dolor sit amet");
      } else {
        model = PRESDB(id: id, value: val!);
      }
      final request = ModelMutations.create(model);
      final response = await Amplify.API.mutate(request: request).response;

      final createdPRESDB = response.data;
      if (createdPRESDB == null) {
        safePrint('errors: ${response.errors}');
        return;
      }
      safePrint('Mutation result: ${createdPRESDB.id}');
    } on ApiException catch (e) {
      safePrint('Mutation failed: $e');
    }
  }

  Future<PRESDB?> getPRESDBById(String id) async {
    try {
      final request = ModelQueries.list(
        PRESDB.classType,
        where: PRESDB.ID.eq(id),
      );
      final response = await Amplify.API.query(request: request).response;

      final item = response.data?.items;
      if (item == null) {
        debugPrint('errors: ${response.errors}');
        return null;
      }
      return item[0];
    } on ApiException catch (e) {
      debugPrint('Query failed: $e');
    }
    return null;
  }

  Future<List<PRESDB?>> queryListItems() async {
    try {
      final request = ModelQueries.list(PRESDB.classType);
      final response = await Amplify.API.query(request: request).response;

      final items = response.data?.items;
      if (items == null) {
        debugPrint('errors: ${response.errors}');
        return <PRESDB?>[];
      }
      return items;
    } on ApiException catch (e) {
      debugPrint('Query failed: $e');
    }
    return <PRESDB?>[];
  }

  Future<void> updatePRESDB(PRESDB originalPRESDB) async {
    final updatedModel =
        originalPRESDB.copyWith(value: DateTime.now().toString());

    final request = ModelMutations.update(updatedModel);
    final response = await Amplify.API.mutate(request: request).response;
    debugPrint('Response: $response');
  }
}
