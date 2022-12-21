// ignore_for_file: public_member_api_docs, sort_constructors_first
class ListID {
  var id = "";
  var title = "";
  var subtitle = "";
  ListID({
    required this.id,
    required this.title,
    required this.subtitle,
  });
  String userAsStringByName() {
    return '#${this.id} ${this.title}';
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
class SearchItem {
  var id = "";
  var title = "";
  var subtitle = "";
  var avatar = "";
  SearchItem({
    required this.id,
    required this.avatar,
    required this.title,
    required this.subtitle,
  });
  String userAsStringByName() {
    return '#${this.id} ${this.title}';
  }
}
