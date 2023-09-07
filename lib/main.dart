import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

//creating the database class that handles all the necessary operations: retrieving and updating;

class DataBasehelper {
  static Database? _database;
  static const String tableName = 'task';

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasepath = await getDatabasesPath();
    final path = join(databasepath, 'task table.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(''' 
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY,
       tasktext TEXT, 
       isliked INTEGER)

''');
      },
    );
  }

  Future<void> insertTask(String taskText, bool isLiked) async {
    final db = await database;
    await db
        .insert(tableName, {'taskText': taskText, 'isliked': isLiked ? 1 : 0});
  }

  Future<List<Map<String, dynamic>>> getAllTask() async {
    final db = await database;
    return await db.query(tableName);
  }

  Future<void> updatetaskLike(int id, bool isLiked) async {
    final db = await database;
    await db.update(
      tableName,
      {'isliked': isLiked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: MainScreen(),
    ),
  );
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<String> Todo = [];
  List<bool> islikedlist = [];
  final TextEditingController txtcontroller = TextEditingController();
  DataBasehelper dbhelPer = DataBasehelper();
  void addt(context) async {
    final taskText = txtcontroller.text;
    await dbhelPer.insertTask(taskText, false);

    setState(() {
      Todo.add(taskText);
      islikedlist.add(false);
    });
    txtcontroller.clear();
    Navigator.pop(context);
  }

  void togglelike(index) {
    setState(() {
      islikedlist[index] = !islikedlist[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'Task APP',
              style: GoogleFonts.baloo2(
                textStyle: const TextStyle(fontSize: 25),
              ),
            ),
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(
                    Icons.list_rounded,
                  ),
                ),
                Tab(
                  icon: Icon(Icons.thumb_up_alt_rounded),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              //this is the content of the list
              ListView.builder(
                itemCount: Todo.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      Todo[index],
                    ),
                    trailing: IconButton(
                        onPressed: () {
                          togglelike(index);
                        },
                        icon: islikedlist[index]
                            ? const Icon(
                                Icons.thumb_up_sharp,
                                color: Colors.red,
                              )
                            : const Icon(Icons.thumb_up)),
                  );
                },
              ),
              //this is for the favourited buttons
              ListView.builder(
                itemCount: islikedlist.length,
                itemBuilder: (context, index) {
                  if (islikedlist[index] == true) {
                    return ListTile(
                      title: Text(
                        Todo[index],
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextField(
                          controller: txtcontroller,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          addt(context);
                        },
                        child: const Icon(Icons.check),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Icon(Icons.add),
          ),
        ));
  }
}
