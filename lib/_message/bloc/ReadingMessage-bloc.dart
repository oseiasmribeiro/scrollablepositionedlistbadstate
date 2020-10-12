import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrollablepositionedlistbadstate/_message/model/Paragraph-model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingMessageBloc extends BlocBase {

  List<Paragraph> listTextParagraph = [];
  double _fontSize = 0;
  int indexReading;

  //============================================= Controller ListMsg =================================================
  Stream<List<Paragraph>> getListMessages() async* {
    yield null;
    try{

      String url = 'https://tabernaculodafe.org.br/busca/json_v0002/19491225.json';
      final response = await http.get(Uri.encodeFull(url), headers: {"Accept":"application/json"});

      if (response.statusCode == 200) {

        String source = Utf8Decoder().convert(response.bodyBytes);
        var messages = jsonDecode(source);
        var paragraphs = messages["paragraphs"] as List;
        List<Paragraph> result = paragraphs.map((x) => Paragraph.fromJson(x)).toList();

        listTextParagraph.clear();
        for(int i=0; i < result.length; i++){
          result[i].checked = false;
          listTextParagraph.add(result[i]);
        }

        yield listTextParagraph;

      } else {
        yield* Stream.error("Nada foi encontrado!");
        return;
      }
    }catch(e){
      yield* Stream.error(e);
    }
  }

//================================================= Font Size ========================================================
  var _controllerFontSize = BehaviorSubject<double>.seeded(20);
  Sink<double> get inValueFontSize=> _controllerFontSize.sink;
  Stream<double> get outValueFontSize => _controllerFontSize.stream;

  changeFontSize(double size) async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('readingMessage_fontSize', size);
    inValueFontSize.add(size);
  }

  getFontSize() async{
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble('readingMessage_fontSize');
    inValueFontSize.add(_fontSize != null ? _fontSize : 20);
  }

  //============================================ Jump Error Message =================================================
  var _controllerJumpParagraphMsgError = BehaviorSubject<String>();
  Sink<String> get inValueJumpParagraphMsgError => _controllerJumpParagraphMsgError.sink;
  Stream<String> get outValueJumpParagraphMsgError => _controllerJumpParagraphMsgError.stream;

  setJumpParagraphMsgError(String text) async{
    inValueJumpParagraphMsgError.add(text);
  }

//=================================== Color Background LongPress For Share =========================================
  var _controllerTotalParagraph = BehaviorSubject<int>();
  Sink<int> get inValueTotalParagraph => _controllerTotalParagraph.sink;
  Stream<int> get outValueTotalParagraph => _controllerTotalParagraph.stream;

  getTotalParagraph() async{
    inValueTotalParagraph.add(148);
  }

  //=================================== Color Background LongPress For Share =========================================
  var _controllerLongPressForShare = BehaviorSubject<bool>.seeded(false);
  Sink<bool> get inValueLongPressForShare => _controllerLongPressForShare.sink;
  Stream<bool> get outValueLongPressForShare => _controllerLongPressForShare.stream;

  changeLongPressForShare(bool isShare, {int code}) async{
    if(isShare == false){
      for(int i=0; i < listTextParagraph.length; i++){
        listTextParagraph[i].checked = false;
      }
    }
    inValueLongPressForShare.add(isShare);
  }

  void addIndexForListChecked(int index) async{
    listTextParagraph[index].checked = true;
  }

  void removeIndexForListChecked(int index) async{
    listTextParagraph[index].checked = false;
  }

  @override
  void dispose() {
    _controllerTotalParagraph.close();
    _controllerLongPressForShare.close();
    _controllerJumpParagraphMsgError.close();
    _controllerFontSize.close();
    super.dispose();
  }
}