// bu sınıf id,title,description adında 3 alan tutan bir sınıftır
// doğrudan veritabanı ile iletişim kuramaz
class Task {
  int? id;
  String title;
  String description;
  // klasik constructor
  Task({required this.title, required this.description, this.id});
  // json ile constructor
  Task.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        id = json['id'],
        description = json['description'];
  // sınıfı json datasına çeviren metot
  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description};
  }
}
