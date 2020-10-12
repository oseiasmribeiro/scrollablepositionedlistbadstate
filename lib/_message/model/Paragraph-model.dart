class Paragraph {

  String number;
  String text;
  bool checked;

  Paragraph(
    {
      this.number,
      this.text,
      this.checked
    }
  );

  factory Paragraph.fromJson(Map<String, dynamic> json) => Paragraph(
      number: json["number"],
      text: json["text"],
  );

  Map<String, dynamic> toJson() => {
      "number": number,
      "text": text,
  };
}