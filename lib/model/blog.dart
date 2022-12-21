class BlogItem {
  var title = "";
  var pk = 0;
  var summary = "";
  var main_image_url = "";
  var youtube_id = "";
  BlogItem(
      {required this.pk,
      required this.title,
      required this.summary,
      required this.youtube_id,
      required this.main_image_url});
}

class BlogItemDetil {
  var title;
  var pk = 0;
  var summary;
  var main_image;
  var main_image_url;
  var content;
  var youtube_id;
  var youtube_embeded;
  var albums_id = [];
  var albums_url = [];

  BlogItemDetil.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        pk = json['pk'],
        summary = json['summary'],
        main_image = json['main_image'],
        main_image_url = json['main_image_url'],
        content = json['content'],
        youtube_id = json['youtube_id'],
        youtube_embeded = json['youtube_embeded'],
        albums_id = json['albums_id'],
        albums_url = json['albums_url'];

  BlogItemDetil({
    required this.title,
    required this.pk,
    required this.summary,
    required this.main_image,
    required this.main_image_url,
    required this.content,
    required this.youtube_id,
    required this.youtube_embeded,
    required this.albums_id,
    required this.albums_url,
  });
}
