class UserLogin {
  var email = "";
  var displayName = "";
  var photoURL = "";
  var uid = "";
  var isLogin = false;
  var idCompany = "";
  var companyName = "";
  var role = "";
  var token = "";

  UserLogin(
      {required this.email,
      required this.displayName,
      required this.photoURL,
      required this.uid,
      required this.isLogin,
      required this.token,
      required this.idCompany,
      required this.companyName,
      required this.role});
}

class ChatUser {
  late final String uid;
  late final String avatar;
  late final String title;
  late final String subtitle;
  ChatUser(this.uid, this.avatar, this.title, this.subtitle);
}
