import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  GlobalKey<RefreshIndicatorState> _refreshKey = new GlobalKey();
  final double _expandedHeight = 200.0;
  String _offset1 = '0', _offset2 = '0';

  ScrollController _controller;
  _buildPrimaryScrollController(BuildContext context) {
    if (_controller == null) {
      _controller = PrimaryScrollController.of(context);
      _controller.addListener(() {
        // 0 to (appBar + expandedHeight): 28 + 200 = 228
        // STOPS AFTER SliverAppBar is scrolled out of view
        //   extentAfter: remaining visible height of SliverAppBar
        int nestedPixel = _controller.position.pixels.round(); // same as controller.offset
        if (nestedPixel > 0) {
          _fabPrint(nestedPixel, null);
        }
      });
    }
    return _controller;
  }

  @override
  void initState() {
    super.initState();
    print('initState');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        return NestedScrollView(
            controller: _buildPrimaryScrollController(context),
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  pinned: false,
                  title: Text(widget.title),
                  backgroundColor: Colors.green,
                  expandedHeight: _expandedHeight,
                ),
              ];
            },
            body: RefreshIndicator(
              key: _refreshKey,
              onRefresh: () => _refresh(),
              child: NotificationListener<ScrollNotification>(
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverList(delegate: SliverChildListDelegate(_buildList()))
                  ]
                ),
                onNotification: (ScrollNotification scrollInfo) {
                  // 0 to maxScrollExtent: total list height
                  // STARTS AFTER SliverAppBar scrolls out of view
                  //   extentInside: current visible height of scrollview
                  //   maxScrollExtent: total height of scrollview contents/list
                  int customPixel = scrollInfo.metrics.pixels.round(); // offset
                  if (customPixel > 0) {
                    _fabPrint(null, customPixel);
                  }
                  return false;
                },
              ),
            )
          );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
        child: Text(_offset1 + "\n" + _offset2, textAlign: TextAlign.center),
      ),
    );
  }

  _buildList() {
    List<Widget> list = new List();
    for (int i = 0; i < 30; i++) {
      list.add(Text('aloha$i', style: new TextStyle(fontSize: 30.0)));
    }
    return list;
  }

  _refresh() async {
    print('refresh');
  }

  _fabPrint(int value1, int value2) {
    setState(() {
      if (value1 != null) {
        _offset1 = value1.toString();
        print('nested=' + _offset1);
      }
      if (value2 != null) {
        _offset2 = value2.toString();
        print('custom=' + _offset2);
      }
    });
  }
}
