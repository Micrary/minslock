import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: library_prefixes
import 'package:path/path.dart' as pathTools;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(title: 'MinSouls'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Lock> locks = List.empty(growable: true);
  Timer? timer;

  bool showingSheet = false;
  String current = "";

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void showSheet(Widget? body) {
    _scaffoldKey.currentState?.showBottomSheet((context) =>
        body ??
        const Center(
          child: Text("错误"),
        ));
  }

  @override
  void initState() {
    super.initState();

    Future(() async {
      load();
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() {});
      });
    });
  }

  void load() async {
    setState(() async {
      locks.clear();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var ls = prefs.getStringList(Lock.key) ?? List.empty();
      for (var item in ls) {
        locks.add(Lock.from(item));
      }
      souls();
    });
  }

  void souls() {
    if (locks.isEmpty) {
      var ds = Lock();
      ds.name = "Demon`s Souls";
      ds.time = DateTime(2009, 2, 5);
      ds.back = "asset/demonsouls.jpg";

      var ds1 = Lock();
      ds1.name = "Dark Souls I";
      ds1.time = DateTime(2011, 9, 22);
      ds1.back = "asset/darksouls1.jpg";

      var bb = Lock();
      bb.name = "Bloodborne";
      bb.time = DateTime(2015, 3, 24);
      bb.back = "asset/bloodborne.jpg";

      var ds2 = Lock();
      ds2.name = "Dark Souls II";
      ds2.time = DateTime(2015, 4, 2);
      ds2.back = "asset/darksouls2.jpg";

      var ds3 = Lock();
      ds3.name = "Dark Souls III";
      ds3.time = DateTime(2016, 3, 24);
      ds3.back = "asset/darksouls3.jpg";

      var sk = Lock();
      sk.name = "SEKIRO : Shadows Die Twice";
      sk.time = DateTime(2019, 3, 22);
      sk.back = "asset/sekiro.jpg";

      var er = Lock();
      er.name = "Elden Ring";
      er.time = DateTime(2022, 1, 22);
      er.back = "asset/eldenring.jpg";
      
      locks.add(er);
      locks.add(sk);
      locks.add(ds3);
      locks.add(ds2);
      locks.add(bb);
      locks.add(ds1);
      locks.add(ds);
    }
  }

  void save() {
    Future(() async {
      List<String> s = List.empty(growable: true);
      for (var item in locks) {
        s.add(item.to());
      }
    });
  }

  Widget cardView(Lock lock) {
    var body = Column(
      children: [
        Row(
          children: [
            Expanded(
                child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              height: 160,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      lock.d0(),
                      style: const TextStyle(
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 8.0,
                              color: Colors.black,
                            ),
                          ],
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      lock.d1(),
                      style: const TextStyle(
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 8.0,
                              color: Colors.black,
                            ),
                          ],
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ))
          ],
        ),
        Row(
          children: [
            Expanded(
                child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Text(
                lock.name,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 8.0,
                      color: Colors.black,
                    ),
                  ],
                ),
                textAlign: TextAlign.end,
              ),
            ))
          ],
        )
      ],
    );

    return Card(
      color: Colors.teal,
      child: Container(
        decoration: lock.back.isEmpty
            ? null
            : BoxDecoration(
                image: DecorationImage(
                    image: lock.back.contains("asset")
                        ? AssetImage(lock.back) as ImageProvider
                        : FileImage(File(lock.back)),
                    fit: BoxFit.cover)),
        margin: const EdgeInsets.symmetric(),
        child: body,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        key: _scaffoldKey,
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () async {
                var res = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (c) => const EditerPage()));
                if (res != null) {
                  setState(() {
                    locks.add(Lock.from(res));
                  });
                  save();
                }
              },
              icon: const Icon(Icons.public))
        ],
      ),
      body: RefreshIndicator(
          onRefresh: () async {
            load();
          },
          child: ListView.builder(
              itemCount: locks.length,
              itemBuilder: (c, i) {
                return cardView(locks[i]);
              })),
    );
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }
}

class Lock {
  String name = "";
  DateTime time = DateTime.now();
  String back = "";

  static const key = "locks";
  static const split = "<-M->";

  static Lock from(String data) {
    var lock = Lock();
    if (data.isEmpty) {
      return lock;
    }
    var ds = data.split(split);
    lock.name = ds[0];
    lock.time = DateTime.fromMillisecondsSinceEpoch(int.parse(ds[1]));
    lock.back = ds[2];
    return lock;
  }

  String to() {
    return name + split + time.millisecondsSinceEpoch.toString() + split + back;
  }

  String d0() {
    var duration = time.difference(DateTime.now());
    return duration.inDays.abs().toString();
  }

  String d1() {
    var duration = time.difference(DateTime.now());
    var hours =
        (duration.inHours.abs() - duration.inDays.abs() * 24).toString();
    var mintes =
        (duration.inMinutes.abs() - duration.inHours.abs() * 60).toString();
    var seconds =
        (duration.inSeconds.abs() - duration.inMinutes.abs() * 60).toString();
    return hours + ":" + mintes + ":" + seconds;
  }

  static Future<String> cache() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    return appDocDir.path;
  }

  static Future<String> saveBack(String file) async {
    var ss = file.split(pathTools.separator);
    var name = ss[ss.length - 1];
    var image = await cache() + pathTools.separator + name;
    await File(file).copy(image);
    return image;
  }
}

class NewOnePage extends StatefulWidget {
  const NewOnePage({Key? key}) : super(key: key);

  @override
  State<NewOnePage> createState() => _NewOnePageState();
}

class _NewOnePageState extends State<NewOnePage> {
  @override
  void initState() {
    super.initState();
    lock.name = "名称";
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {});
    });
  }

  Lock lock = Lock();
  Timer? timer;

  var tec = TextEditingController();

  String info = "";
  bool isName = true;
  bool isTime = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                Fluttertoast.showToast(
                    msg: "点击文字位置输入，空白位置选择图片", toastLength: Toast.LENGTH_LONG);
              },
              icon: const Icon(Icons.ac_unit_sharp)),
          IconButton(
              onPressed: () {
                var data = lock.to();
                Navigator.of(context).pop(data);
              },
              icon: const Icon(Icons.timer))
        ],
      ),
      bottomSheet: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: TextField(
          controller: tec,
          maxLines: 1,
          decoration: InputDecoration(
              suffixIcon: IconButton(
                  onPressed: () {
                    if (isName) {
                      lock.name = tec.text;
                    } else if (isTime) {
                      var data = tec.text.split(' ');
                      if (data.length >= 3 && data.length < 5) {
                        lock.time = DateTime(int.parse(data[0]),
                            int.parse(data[1]), int.parse(data[2]));
                      } else if (data.length >= 5) {
                        lock.time = DateTime(
                          int.parse(data[0]),
                          int.parse(data[1]),
                          int.parse(data[2]),
                          int.parse(data[3]),
                          int.parse(data[4]),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.sentiment_satisfied_alt)),
              labelText: info,
              border: const OutlineInputBorder()),
        ),
      ),
      body: ListView(
        children: [
          Card(
            color: Colors.teal,
            child: InkWell(
              child: Container(
                decoration: lock.back.isEmpty
                    ? null
                    : BoxDecoration(
                        image: DecorationImage(
                            image: lock.back.contains("asset")
                                ? AssetImage(lock.back) as ImageProvider
                                : FileImage(File(lock.back)),
                            fit: BoxFit.cover)),
                margin: const EdgeInsets.symmetric(),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Container(
                          margin: const EdgeInsets.symmetric(),
                          height: 160,
                          child: Center(
                            child: InkWell(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    lock.d0(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(1.0, 1.0),
                                            blurRadius: 8.0,
                                            color: Colors.black,
                                          ),
                                        ],
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    lock.d1(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(1.0, 1.0),
                                            blurRadius: 8.0,
                                            color: Colors.black,
                                          ),
                                        ],
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  isName = false;
                                  isTime = true;
                                  info = "时间 ： 2022 1 22 / 2022 1 22 0 0";
                                });
                              },
                            ),
                          ),
                        ))
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: InkWell(
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            child: Text(
                              lock.name,
                              style: const TextStyle(
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 8.0,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              isName = true;
                              isTime = false;
                              info = "名称";
                            });
                          },
                        ))
                      ],
                    )
                  ],
                ),
              ),
              onTap: () async {
                final ImagePicker _picker = ImagePicker();
                final XFile? image =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    lock.back = image.path;
                  });
                }
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    if (lock.back.isNotEmpty) {
      lock.back = await Lock.saveBack(lock.back);
    }
    timer?.cancel();
  }
}

class EditerPage extends StatefulWidget {
  const EditerPage({Key? key}) : super(key: key);

  @override
  State<EditerPage> createState() => _EditerPageState();
}

class _EditerPageState extends State<EditerPage> {
  List<Lock> locks = List.empty(growable: true);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    Future(() async {
      load();

      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() {});
      });
    });
  }

  void save() {
    Future(() async {
      List<String> s = List.empty(growable: true);
      for (var item in locks) {
        s.add(item.to());
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList(Lock.key, s);
    });
  }

  void load() async {
    setState(() async {
      locks.clear();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var ls = prefs.getStringList(Lock.key) ?? List.empty();
      for (var item in ls) {
        locks.add(Lock.from(item));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                Fluttertoast.showToast(
                    msg: "长按上移 双击删除\n刷新撤销 返回会保存",
                    toastLength: Toast.LENGTH_LONG);
              },
              icon: const Icon(Icons.ac_unit_sharp)),
          IconButton(
              onPressed: () async {
                var res = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (c) => const NewOnePage()));
                if (res != null) {
                  setState(() {
                    locks.add(Lock.from(res));
                  });
                  save();
                }
              },
              icon: const Icon(Icons.more_time_rounded))
        ],
      ),
      body: RefreshIndicator(
          onRefresh: () async {
            load();
          },
          child: ListView.builder(
              itemCount: locks.length,
              itemBuilder: (c, i) {
                return cardView(locks[i]);
              })),
    );
  }

  Widget cardView(Lock lock) {
    var body = Column(
      children: [
        Row(
          children: [
            Expanded(
                child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              height: 160,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      lock.d0(),
                      style: const TextStyle(
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 8.0,
                              color: Colors.black,
                            ),
                          ],
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      lock.d1(),
                      style: const TextStyle(
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 8.0,
                              color: Colors.black,
                            ),
                          ],
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ))
          ],
        ),
        Row(
          children: [
            Expanded(
                child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Text(
                lock.name,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 8.0,
                      color: Colors.black,
                    ),
                  ],
                ),
                textAlign: TextAlign.end,
              ),
            ))
          ],
        )
      ],
    );

    return Card(
      color: Colors.teal,
      child: Container(
        decoration: lock.back.isEmpty
            ? null
            : BoxDecoration(
                image: DecorationImage(
                    image: lock.back.contains("asset")
                        ? AssetImage(lock.back) as ImageProvider
                        : FileImage(File(lock.back)),
                    fit: BoxFit.cover)),
        margin: const EdgeInsets.symmetric(),
        child: InkWell(
          child: body,
          onLongPress: () {
            var index = locks.indexOf(lock) - 1;
            index = index < 0 ? 0 : index;
            setState(() {
              locks.removeAt(index + 1);
              locks.insert(index, lock);
            });
          },
          onDoubleTap: () {
            setState(() {
              locks.remove(lock);
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    save();
  }
}
