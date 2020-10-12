import 'Paragraph-model.dart';

class Message {
  
    String code;
    String title;
    String date;
    String place;
    String translation;
    List<Paragraph> paragraphs;

    Message({
        this.code,
        this.title,
        this.date,
        this.place,
        this.translation,
        this.paragraphs,
    });

    factory Message.fromJson(Map<String, dynamic> json) => Message(
        code: json["code"],
        title: json["title"],
        date: json["date"],
        place: json["place"],
        translation: json["translation"],
        paragraphs: List<Paragraph>.from(json["paragraphs"].map((x) => Paragraph.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "title": title,
        "date": date,
        "place": place,
        "translation": translation,
        "paragraphs": List<dynamic>.from(paragraphs.map((x) => x.toJson())),
    };
}