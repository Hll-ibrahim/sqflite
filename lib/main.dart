import 'package:flutter/material.dart';
import 'package:veritabani/task.dart';
import 'package:veritabani/task_helper.dart';

main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  // veritabanı controller nesnesi
  late TaskDataBase taskDataBase;
  // görev sayısı
  int sayi = -1;
  // görevlerin tutulacağı liste
  List<Task> taskList = [];
  // form için key
  static final formState = GlobalKey<FormState>();
  // scaffold için key
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  // tabcontroller nesnesini fonksiyonlada kontrol etmek için bir nesne lazım
  late final TabController _tabController = TabController(length: 2, vsync: this);

  //final scaffoldSubkey = GlobalKey<ScaffoldState>();
  @override
  initState() {
    super.initState();
    print("sayfa init ediliyor..");
    // veritabanı bağlan
    baglan();
    // tabcontroller tetiklendiğinde setstate ile sayfa yenileniyor
    _tabController.addListener(() {
      setState(() {});
    });
  }

  baglan() {
    // nesne oluşturulur
    taskDataBase = TaskDataBase();
    // veritabanından kayıtlar çekilir, aslında fonksiyonun adı getUsers olmalıydi, daha anlaşılır olabilir
    getUserNumber();
  }

  getUserNumber([String kelime = ""]) async {
    // taskDataBase.getTasks(kelime).then((value) => {
    //       setState(() {
    //         taskList = value;
    //         sayi = taskList.length;
    //       })
    //     });
    //üstteki kullanımda olabilir, bu direk fonksiyondan satırları çekiyor
    taskList = await taskDataBase.getTasks(kelime);
    // görev sayısını atama yapıyor
    sayi = taskList.length;
    // sayfa yenileme
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print("sayfa build ediliyor...");
    return MaterialApp(
      scaffoldMessengerKey: scaffoldKey,
      debugShowCheckedModeBanner: false,
      title: 'Yapılacaklar Listesi',
      // tema ayarları
      theme: ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          )),
      darkTheme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          )),
      home: Scaffold(
          appBar: AppBar(
            title: Text("Görevler"),
            //bottom: tabbar,
          ),
          bottomNavigationBar: buttomNavigation(),
          body: DefaultTabController(
            length: 2,
            initialIndex: 0,
            child: TabBarView(controller: _tabController, children: [
              // tabbar içeriği, 2 sayfa var
              notListesi(),
              addForm(context),
            ]),
          )),
    );
  }

  BottomNavigationBar buttomNavigation() {
    return BottomNavigationBar(
        currentIndex: _tabController.index,
        onTap: (index) {
          _tabController.animateTo(index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Listele",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Ekle"),
        ]);
  }

  final FocusNode t1 = FocusNode();
  final FocusNode t2 = FocusNode();
  Widget addForm(BuildContext context) {
    //var formState = GlobalKey<FormState>();
    String _txtTitle = "";
    String _txtDescription = "";
    // Ekleme formu içeriği
    return Form(
      key: formState,
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('başlık'),
            TextFormField(
              focusNode: t1,
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Başlık boş olamaz";
                }
              },
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(t2);
              },
              onSaved: (newValue) => _txtTitle = newValue!,
            ),
            const Divider(),
            const Text('İçerik'),
            TextFormField(
              focusNode: t2,
              minLines: 3,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              validator: (value) {
                if (value!.isEmpty || value.length < 5) {
                  return "İçerik boş olamaz";
                }
              },
              onSaved: (newValue) => _txtDescription = newValue!,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ElevatedButton(
                  child: Text("Ekle"),
                  onPressed: () {
                    // form validate kontrolü
                    if (formState.currentState!.validate()) {
                      formState.currentState!.save();
                      taskDataBase.addTask(Task(title: _txtTitle, description: _txtDescription)).then((value) => {
                        if (value == -1) {showSnack("Görev eklenemedi")} else {showSnack("Görev eklendi $value")}
                      });
                      // başarılı veya başarısız ise yukarıda snackbar gösterilir
                      // form reset edilir
                      formState.currentState!.reset();
                      FocusScope.of(context).requestFocus(FocusNode());
                      // listeleme sekmesine döner
                      _tabController.animateTo(0);
                      // o arada yine kayıtları çeker, yeni eklenenle birlikte
                      getUserNumber();
                      setState(() {});
                    }
                    // Navigator.pop(context);
                  }),
              TextButton(
                  child: Text("Listeye dön"),
                  onPressed: () {
                    // ilk sayfaya döner
                    _tabController.animateTo(0);
                  }),
            ]),
          ],
        ),
      ),
    );
  }

  Widget notListesi() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          filterTasks(),
          sayi <= 0 ? Text("Görev yok") : taskListPage2()
          // burada eğer sıfırdan büyükse listelenir, değilse görev yok yazar, üstünde arama simgesi sabit
        ],
      ),
    );
  }

  var textEditVariable = TextEditingController();
  Widget taskListPage2() {
    var _titleController = TextEditingController();
    var _descriptionController = TextEditingController();
    var _formState = GlobalKey<FormState>();
    return Expanded(
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: taskList.length,
          itemBuilder: (context, index) {
            return Card(
                child: ListTile(
                  // her bir görev için ListTile ile listeleme
                  leading: duzenleButon(_titleController, index, _descriptionController, context, _formState),
                  trailing: gorevSilButon(context, index),
                  title: Text(taskList[index].title),
                  subtitle: Text(taskList[index].description),
                ));
          }),
    );
  }

  InkWell duzenleButon(
      TextEditingController _titleController, int index, TextEditingController _descriptionController, BuildContext context, GlobalKey<FormState> _formState) {
    return InkWell(
      onTap: () {
        _titleController.text = taskList[index].title;
        _descriptionController.text = taskList[index].description;
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                  height: 500,
                  padding: EdgeInsets.all(20),
                  child: Form(
                    key: _formState,
                    child: Column(children: [
                      Text("Başlık"),
                      TextFormField(
                        controller: _titleController,
                      ),
                      Text("İçerik"),
                      TextFormField(
                        minLines: 2,
                        maxLines: 4,
                        controller: _descriptionController,
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Kapat"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // fonksiyona gönderilmek için Task nesnesi hazırlanır
                            Task t = Task(id: taskList[index].id, title: _titleController.text, description: _descriptionController.text);
                            // fonksiyona gönderilir
                            taskDataBase.updateTask(t);
                            // güncelleme yapılır
                            getUserNumber();
                            // bildirim
                            showSnack("Güncellendi");
                            // açılan ekranı kapatma
                            Navigator.pop(context);
                          },
                          child: Text("Güncelle"),
                        )
                      ])
                    ]),
                  ));
            });
      },
      child: Icon(Icons.edit_sharp, color: Theme.of(context).primaryColorDark),
    );
  }

  IconButton gorevSilButon(BuildContext context, int index) {
    return IconButton(
        color: Colors.red,
        icon: Icon(Icons.delete),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    title: Text("Sil"),
                    content: Text(
                      "Eminmisiniz?",
                    ),
                    actions: [
                      TextButton(
                        child: Text("İptal"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                          child: Text("Sil"),
                          onPressed: () {
                            // burada ise sil e tıklanınca açılan pencerenin içeriği ve detayı
                            taskDataBase.deleteTask(taskList[index].id!).then((value) => {
                              if (value < 1) {showSnack("Görev silinemedi")} else {showSnack("Görev silindi")}
                            });
                            setState(() {
                              taskList.removeAt(index);
                            });

                            Navigator.pop(context);
                          })
                    ]);
              });
          setState(() {});
        });
  }

// snackbar gösterimi için özelleştirilmiş fonksiyon
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnack(String msg) {
    return scaffoldKey.currentState!.showSnackBar(
      SnackBar(
        content: Text(
          msg,
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // üstte sabit çıkan arama alanı
  Padding filterTasks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextFormField(
        controller: textEditVariable,
        autofocus: false,
        onChanged: (value) {
          // her değişiklikte fonksiyon cagrılıyor
          getUserNumber(value);
        },
        decoration: InputDecoration(
          labelText: 'Search..',
          suffixIcon: IconButton(
              onPressed: () {
                // temizle işaretine tıklayınca, içeriği temizle ve yeniden verileri çek
                textEditVariable.clear();
                getUserNumber();
              },
              icon: Icon(Icons.clear_outlined)),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
