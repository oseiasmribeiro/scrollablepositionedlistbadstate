import 'dart:async';
import 'dart:collection';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter/foundation.dart';
import 'package:share/share.dart';
import 'bloc/ReadingMessage-bloc.dart';
import 'model/Paragraph-model.dart';

class MyApp extends StatelessWidget {

  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ListMessage(),
    );
  }
}

class ListMessage extends StatelessWidget {

  final bool isSearchBar = false;
  final ReadingMessageBloc _bloc = BlocProvider.getBloc<ReadingMessageBloc>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Mensagens'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Abrir Mensagem'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReadingMessage()),
            ).then(
              (isSearchBar){
                _bloc.listTextParagraph.clear();
                _bloc.changeLongPressForShare(false);
                FocusScope.of(context).requestFocus(FocusNode());
              }
            );
          },
        ),
      ),
    );
  }
}

class ReadingMessage extends StatefulWidget {
  final bool isSearch;
  final int code;
  final String title;
  final String local;
  final String date;
  final String translation;

  final String searchText;
  final int considerInParagraph;
  final bool isPlural;
  final int paragraph;
  final String paragraphSnippet;

  ReadingMessage({Key key, this.isSearch, this.searchText, this.considerInParagraph, this.isPlural, this.paragraph, this.paragraphSnippet, this.code, this.title, this.local, this.date, this.translation}) : super(key: key);

  @override
  _ReadingMessageState createState() => _ReadingMessageState();
}

class _ReadingMessageState extends State<ReadingMessage> {

  ItemScrollController _itemScrollController;
  ItemPositionsListener _itemPositionListener;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final ReadingMessageBloc _bloc = BlocProvider.getBloc<ReadingMessageBloc>();
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isThemeDark = false;
  bool _isLongPressForShare = false;
  bool _isShareParagraphs = false;
  Map<String, dynamic> _shareParagraphs = Map();
  double _fontSize = 0;
  Stream<List<Paragraph>> _getListTextParagraphMessage;
  Stream<int> _totalParagraphInMessage;
  Stream<String> _jumpParagraphMsgError;
  Stream<bool> _longPressForShare;
  Stream<double> _outValueFontSize;

  @override
  void initState() {
    _itemScrollController = ItemScrollController();
    _itemPositionListener = ItemPositionsListener.create();
    _getListTextParagraphMessage = _bloc.getListMessages();
    _longPressForShare = _bloc.outValueLongPressForShare;
    _totalParagraphInMessage = _bloc.outValueTotalParagraph;
    _jumpParagraphMsgError = _bloc.outValueJumpParagraphMsgError;
    _outValueFontSize = _bloc.outValueFontSize;
  
    _itemPositionListener.itemPositions.addListener(() {
      print(_itemPositionListener.itemPositions.value.first.index + 2);
    });
    
    super.initState();
  }

  // Saltar para o parágrafo
  void _jumpParagraph(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<int>(
          stream: _totalParagraphInMessage,
          builder: (context, snapshotOutValueTotalParagraphs) {
            if (snapshotOutValueTotalParagraphs.data == null) {
              return Center(child: CircularProgressIndicator());
            }

            int totalParagraph = snapshotOutValueTotalParagraphs.data;

            // return object of type Dialog
            return AlertDialog(
              title: new Text("Ir para o parágrafo"),
              content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TextField(
                        keyboardType: TextInputType.number,
                        controller: _textEditingController,
                        focusNode: _focusNode,
                        style: TextStyle(color: _isThemeDark ? Colors.white : Colors.black, fontSize: 18),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _isThemeDark ? Colors.black : Colors.white,
                          hintText: "digite de 1 a $totalParagraph",
                          hintStyle: TextStyle(color: Colors.grey),
                        )
                      ),
                      StreamBuilder<String>(
                        stream: _jumpParagraphMsgError,
                        builder: (context, snapshotOutValueJumpParagraphMsgError) {
                          if (snapshotOutValueJumpParagraphMsgError.data == null) {
                            return Container();
                          }
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("${snapshotOutValueJumpParagraphMsgError.data}", style: TextStyle(color: Colors.red)),
                          );
                        }
                      )
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Cancelar"),
                  onPressed: () {
                    _textEditingController.clear();
                    _bloc.setJumpParagraphMsgError("");
                    Navigator.pop(context);
                  },
                ),
                new FlatButton(
                  child: new Text("Ok"),
                  onPressed: () {
                    if (_textEditingController.text == "") {
                      _bloc.setJumpParagraphMsgError("Digite um número maior que 1\ne menor que $totalParagraph");
                    } else if (int.parse(_textEditingController.text) < 1) {
                      _bloc.setJumpParagraphMsgError("O número dever ser maior que 1");
                    } else if (int.parse(_textEditingController.text) > totalParagraph) {
                      _bloc.setJumpParagraphMsgError("O número dever ser\nmenor que $totalParagraph");
                    } else {
                      _itemScrollController.scrollTo(index: int.parse(_textEditingController.text), duration: Duration(milliseconds: 20));
                      _textEditingController.clear();
                      _bloc.setJumpParagraphMsgError("");
                      Navigator.pop(context);
                    }
                  },
                )
              ],
            );
          }
        );
      },
    );
  }

  // Modificar Tamanho da Fonte
  void _mbsFontSize(context) {
    showModalBottomSheet(
      isScrollControlled: false,
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<double>(
          stream: _bloc.outValueFontSize,
          builder: (context, snapshotOutValueFontSize) {
            if (snapshotOutValueFontSize.data == null) {
              return Center(child: CircularProgressIndicator());
            }
            _fontSize = snapshotOutValueFontSize.data;          
            return Container(
              padding: EdgeInsets.only(top: 10),
              height: 80,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[Text("Tamanho da Fonte", style: TextStyle(fontSize: 16))],
                  ),
                  StreamBuilder<double>(
                    initialData: _fontSize,
                    stream: _outValueFontSize,
                    builder: (context, snapshotOutValueFontSize) {
                      if (snapshotOutValueFontSize.data == null) {
                        return CircularProgressIndicator();
                      }
                      _fontSize = snapshotOutValueFontSize.data;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FlatButton(
                            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(7.0)),
                            color: Colors.blue,
                            child: Icon(Icons.remove, color: Colors.white),
                            onPressed: () {
                              _bloc.changeFontSize(_fontSize - 1);
                            },
                          ),
                          SizedBox(width: 25),
                          Text("${_fontSize.toInt()}"),
                          SizedBox(width: 25),
                          FlatButton(
                            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(7.0)),
                            color: Colors.blue,
                            child: Icon(Icons.add, color: Colors.white),
                            onPressed: () {
                              _bloc.changeFontSize(_fontSize + 1);
                            },
                          ),
                        ],
                      );
                    }
                  ),
                ],
              )
            );
          }
        );
      }
    );
  }

  // Compartilhar Parágrafo
  void _shareParagraph(ReadingMessageBloc bloc, AsyncSnapshot<List<Paragraph>> listIndexForChecked, int index, bool longPress) {
    bloc.changeLongPressForShare(true);
    String key = "${listIndexForChecked.data[index].number}";
    String value = "${listIndexForChecked.data[index].text}";
    longPress = !listIndexForChecked.data[index].checked;
    if (longPress) {
      if (!_shareParagraphs.containsKey(key)) {
        _shareParagraphs[key] = value;
      }
      bloc.addIndexForListChecked(index);
    } else {
      if (_shareParagraphs.containsKey(key)) {
        _shareParagraphs.remove(key);
      }
      bloc.removeIndexForListChecked(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    _bloc.getFontSize();
    _bloc.getTotalParagraph();
    _textEditingController..addListener(() {
        _bloc.setJumpParagraphMsgError("");
      }
    );
    return StreamBuilder<bool>(
      stream: _longPressForShare,
      builder: (context, snapshotOutValueLongPressForShare) {
        if (snapshotOutValueLongPressForShare.hasData) {
          _isLongPressForShare = snapshotOutValueLongPressForShare.data;
          return WillPopScope(
            onWillPop: () async => !_isLongPressForShare,
            child: Scaffold(
                key: _scaffoldKey,
                appBar: AppBar(
                  title: Text("Mensagem"),
                  leading: _isLongPressForShare
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.white),
                      onPressed: () async {
                        _shareParagraphs.clear();
                        _isShareParagraphs = false;
                        _bloc.changeLongPressForShare(false, code: widget.code);
                      }
                    )
                  : IconButton(
                      icon: new Icon(Icons.arrow_back),
                      onPressed: () async {
                        Navigator.of(context).pop(false);
                      }
                    ),
                  actions: <Widget>[
                    PopupMenuButton(
                      onSelected: (value){
                        switch(value) {
                          case 0 :
                            _mbsFontSize(context);
                            break;
                          case 1 :
                            _jumpParagraph(context);
                            break;
                        }
                      },
                      itemBuilder: (context) {
                        var list = List<PopupMenuEntry<Object>>();
                        list.add(
                          PopupMenuItem(
                            child: Text("Tamanho da Fonte"),
                            value: 0,
                          ),
                        );
                        list.add(
                          PopupMenuDivider(
                            height: 10,
                          ),
                        );
                        list.add(
                          PopupMenuItem(
                            child: Text("Ir para o Parágrafo"),
                            value: 1,
                          )
                        );
                        return list;
                      },
                    )
                  ],
                ),
                body: StreamBuilder<List<Paragraph>>(
                  stream: _getListTextParagraphMessage,
                  builder: (context, snapshotGetParagraphs) {
                    
                    if (snapshotGetParagraphs.hasError) {
                      return Center(child: Text(snapshotGetParagraphs.error.toString(), style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)));
                    }
                    
                    if (snapshotGetParagraphs.data == null) {
                      return Center(child: CircularProgressIndicator());
                    } 

                    bool longPress = false;  

                    return StreamBuilder<double>(
                      stream: _outValueFontSize,
                      builder: (context, snapshotOutValueFontSize) {
                        
                        if (snapshotOutValueFontSize.data == null) {
                          return Center(child: CircularProgressIndicator());
                        }
                        
                        _fontSize = snapshotOutValueFontSize.data;
                        
                        return Column(
                          children: [
                            Expanded(
                              child: ScrollablePositionedList.builder(
                                initialScrollIndex: 0,
                                itemScrollController: _itemScrollController,
                                itemPositionsListener: _itemPositionListener,
                                itemCount: snapshotGetParagraphs.data.length,
                                itemBuilder: (context, index) {
                                  
                                  if (snapshotGetParagraphs.data.length > 0) {
                                    if(index == 0){
                                      return Container(
                                        decoration: new BoxDecoration(color: _isThemeDark ? Colors.black : Colors.white, border: new Border(bottom: BorderSide(color: _isThemeDark ? Colors.black : Colors.grey))),
                                        padding: const EdgeInsets.only(bottom: 7, top: 7),
                                        alignment: FractionalOffset.center,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text('A DEIDADE DE JESUS CRISTO', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                                              Text('Jeffersonville - Indiana - E.U.A.', textAlign: TextAlign.center),
                                              Text('25 de dezembro de 1949', textAlign: TextAlign.center),
                                              Text("Tradução: Tabernáculo da Fé - Goiania - GO", textAlign: TextAlign.center),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      index = index - 1;
                                      String numberParagraph = snapshotGetParagraphs.data[index].number.toString();
                                      String textParagraph = snapshotGetParagraphs.data[index].text.toString();
                                      String textPrgNoNumAndTab = textParagraph.replaceAll(new RegExp(r'^[\d-\t]+'), "");
                                      return Container(
                                        color: snapshotGetParagraphs.data[index].checked ? _isThemeDark ? Colors.white12 : Colors.blue[100] : null,
                                        child: GestureDetector(
                                          onLongPress: () {
                                            _isShareParagraphs = true;
                                            _shareParagraph(_bloc, snapshotGetParagraphs, index, longPress);
                                          },
                                          onTap: () {
                                            if (_isShareParagraphs) {
                                            _shareParagraph(_bloc, snapshotGetParagraphs, index, longPress);
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 12, top: 2, right: 12, bottom: 2),
                                            child: Container(
                                              child: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(text: numberParagraph, style: TextStyle(inherit: true, fontSize: _fontSize, color: Colors.blue)),
                                                    TextSpan(text: "  " + textPrgNoNumAndTab, style: TextStyle(fontSize: _fontSize, color: _isThemeDark ? Colors.white : Colors.black))
                                                  ]
                                                ),
                                              ),
                                            )
                                          )
                                        )
                                      );
                                    }
                                  } else {
                                    return Container();
                                  }
                                }
                              )
                            ),
                            _isLongPressForShare ?
                            Container(
                              color: _isThemeDark ? Colors.black26 : Colors.blueGrey[100],
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8, left: 8, top: 8, bottom: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    FlatButton(
                                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(7.0)),
                                      color: Colors.blue,
                                      child: Text("Compartilhar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                      onPressed: () {
                                        var sortedKeys = _shareParagraphs.keys.toList();
                                        var sortedKeysNumber = sortedKeys.map(int.parse).toList();
                                        sortedKeysNumber..sort((num1, num2) => num1 - num2);
                                        LinkedHashMap sortedMap = new LinkedHashMap.fromIterable(sortedKeysNumber, key: (k) => k, value: (k) => _shareParagraphs["$k"]);
                                        String text = "";
                                        sortedMap.forEach((k, v) {
                                          text += "$k $v\n";
                                        });
                                        Share.share('A DEIDADE DE JESUS CRISTO\n25 de dezembro de 1949\nJeffersonville - Indiana - E.U.A.\n${text}Rev. William M. Branham\nBusca App');
                                      },
                                    ),
                                  ],
                                ),
                              )
                            )
                            : Container()
                          ]
                        );
                      }
                    );
                  }
                )
              )
            );
        } else {
          return Container();
        }
      },
    );
  }

  @override
  void dispose() async {
    super.dispose();
    _textEditingController.dispose();
  }
}