import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:launch_review/launch_review.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usatolebanese/globals/logics/constants.dart';
import 'package:usatolebanese/pages/drawer/change_currency/change.dart';
import 'package:usatolebanese/pages/drawer/currency_value/value.dart';
import 'package:usatolebanese/pages/out/chart/use_of_widget/root.dart';
import 'package:usatolebanese/utility/localization/localization.dart';

class BaseLogic extends ChangeNotifier {
  InterstitialAd fullScreenAd;
  AnimationController controller;
  Animation<Offset> animation;
  AnimationController rotationController;
  Animation<double> rotationAnimation;
  AnimationController scaleController;
  Animation<double> scaleAnimation;

  AnimationController colorController;
  Animation<Color> colorAnimation;
  final FirebaseMessaging fireBaseMessaging = FirebaseMessaging();
  bool isReadyToRate;
  InterstitialAd createFullScreenAd() {
    return InterstitialAd(
      adUnitId: Constants.secondAdCode,
    );
  }

/*
* بعد ذلك، ضع الوحدة الإعلانية داخل تطبيقك
اتبع هذه التعليمات:
أكمِل التعليمات في دليل حزمة SDK لإعلانات Google على الأجهزة الجوّالة باستخدام رقم تعريف التطبيق التالي:
ca-app-pub-5221499382551302~9992907849
اتّبع دليل تنفيذ إعلانات البانر لدمج حزمة SDK. ستحدّد نوع الإعلان وحجمه وموضعه عند دمج الرمز باستخدام رقم تعريف الوحدة الإعلانية التالي:
ca-app-pub-5221499382551302/9801336152
راجع سياسات AdMob لضمان التزام عملية تنفيذ الإعلانات.



بعد ذلك، ضع الوحدة الإعلانية داخل تطبيقك
اتبع هذه التعليمات:
أكمِل التعليمات في دليل حزمة SDK لإعلانات Google على الأجهزة الجوّالة باستخدام رقم تعريف التطبيق التالي:
ca-app-pub-5221499382551302~9992907849
اتّبع دليل تنفيذ الإعلانات البينية لدمج حزمة SDK. ستحدّد نوع الإعلان وموضعه عند دمج الرمز باستخدام رقم تعريف الوحدة الإعلانية التالي:
ca-app-pub-5221499382551302/5670519450
راجع سياسات AdMob لضمان التزام عملية تنفيذ الإعلانات.



*/
  void showAd() {
    FirebaseAdMob.instance
        .initialize(appId: 'ca-app-pub-5221499382551302~9992907849')
        .then((x) {
      fullScreenAd = createFullScreenAd()
        ..load()
        ..show();
    });
  }

  int index = 0;
  Map<String, dynamic> data;
  var pages;
  bool isLoading = true;
  List<Map> currencyTypes;
  List<DocumentSnapshot> documents;
  void fetchData() {
    if (isLoading == false) isLoading = true;
    notifyListeners();
    Future.wait([
      Firestore.instance.collection('Pounds').document('Lebanese').get(),
      Firestore.instance.collection('Pounds').document('Syrian').get(),
      Firestore.instance.collection('Pounds').document('Turkey').get(),
      Firestore.instance.collection('Pounds').document('Euro').get(),
      Firestore.instance.collection('Pounds').document('Egypt').get(),


    ]).then((x) {
      documents = x;
      currencyTypes = List.generate(6, (index) {
        return {
          'name': localization[index],
          'value': index == 0 ? 1 : documents[index - 1].data['buy']['to']
        };
      });

      isLoading = false;
      notifyListeners();
    });
  }

  int syrianPrice, lebanonPrice;
  var lastPrices = {};
  AnimationController animationController;

  List<String> localization;
  Widget icon(String x, Map<String, dynamic> data) {
    if (data[x]['to'] > data[x]['from']) {
      return Icon(
        Icons.keyboard_arrow_up,
        color: Colors.green,
      );
    } else {
      return Icon(
        Icons.keyboard_arrow_down,
        color: Colors.red,
      );
    }
  }

  int openApp;
  double screenWidth, screenHeight, aspectRatio;
  Size size;
  BuildContext context;
  Widget snackBar;
  void showSnackBar(int index) {
    ScaffoldState scaffoldState = scaffoldKey?.currentState as ScaffoldState;

    scaffoldState?.showSnackBar(SnackBar(
        duration: Duration(minutes: 1),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        behavior: SnackBarBehavior.fixed,
        action: SnackBarAction(
            label: 'Refresh',
            onPressed: () {
              fetchData();
            }),
        content: Text(
          'The prices is refreshed check the last update now by clicking on refresh button ',
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
        )));
  }

  void indexing(int index) {
    this.index = index;
    notifyListeners();
  }

  List tilesTab;
  bool isLoadContext = false;
  var scaffoldKey = GlobalKey();

  BaseLogic(BuildContext context, TickerProvider tickerProvider) {
    var local = Localization.of(context).rateApp;
    this.context = context;
    double height = (MediaQuery.of(context).size.height);
    bool bigScreenSize = height >= 792;

    SharedPreferences.getInstance().then((instance) {
      int timesOfOpenApp = instance.getInt('timesOfOpenApp');
      bool isRated = instance.getBool('isRated');
      if (timesOfOpenApp == null || isRated == null) {
        instance.setInt('timesOfOpenApp', 0);
        instance.setBool('isRated', false);
      } else {
        if (isRated == false) {
          instance.setInt('timesOfOpenApp', timesOfOpenApp + 1);
          if (timesOfOpenApp % 15 == 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        local[0],
                        style: Theme.of(context)
                            .textTheme
                            .headline
                            .copyWith(color: Colors.black87),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () {
                            rateApp();
                          },
                          child: Text(local[1]),
                        ),
                        FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(local[2]),
                        )
                      ],
                    );
                  });
            });
          }
        }
      }
    });
//    fireBaseMessaging.configure(
//      onMessage: (Map<String, dynamic> message) async {
//        indexing(message['data']['index']);
//        int index = message['data']['index'];
//        print(message['data']);
//        print(message['data']['index']);
//        this.index = index;
//        notifyListeners();
//        message['data'].forEach((k, v) {
//          print(k);
//          if (k != 'index') {
//            documents[index].data[k]['to'] = documents[index].data[k]['from'];
//            documents[index].data[k]['to'] = v;
//          }
//        });
//
//        notifyListeners();
//        showSnackBar(message['index']);
//      },
//    );

    pages = [CurrencyValue(), CurrencyValue(), Change(context)];

    fetchData();
    showAd();
    size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;
    aspectRatio = size.aspectRatio;
    localization = Localization.of(context).currencyTypes;
    controller = AnimationController(
      vsync: tickerProvider,
      duration: Duration(milliseconds: 800),
    );
    animation = Tween<Offset>(begin: Offset(0, -0.15), end: Offset(0, 0.2))
        .animate(controller);
    rotationController = AnimationController(
      vsync: tickerProvider,
      duration: Duration(milliseconds: 800),
    );
    rotationAnimation =
        Tween<double>(begin: 0, end: 1).animate(rotationController);
    colorController = AnimationController(
      vsync: tickerProvider,
      duration: Duration(milliseconds: 200),
    );
    colorAnimation = ColorTween(begin: Colors.white, end: Colors.pinkAccent)
        .animate(colorController);
    scaleController = AnimationController(
      vsync: tickerProvider,
      duration: Duration(seconds: 2),
    );

    controller.repeat(reverse: true);
    scaleAnimation = Tween<double>(begin: 1, end: 1.1).animate(
        CurvedAnimation(parent: scaleController, curve: Curves.easeInOutCirc));
    if (!bigScreenSize) scaleController.repeat(reverse: true);
  }
  bool isShareReady = false;
  void initPref() async {
    var instance = await SharedPreferences.getInstance();
    int num = instance.getInt('openApp') ?? 0;

    instance.setInt('openApp', num += 1).then((x) {
      if (num % 7 == 0) {
        isShareReady = true;
      }
    });
  }



  void openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }
void pop(){
  Navigator.pop(context);

}
  void navigateToPage(BuildContext context, int i) {
    pop();

    index = i;
    notifyListeners();
  }

  void shareApp() {
    pop();

    Share.share(
        'بين الـ 1500 و3000، الدولار طالع نازل! ما تخلّي حدا يغشّك وخلّيك على اطلاع بكافّة التغيّرات بسعر الدولار.ببساطة نزل هالتطبيق الأول من نوعه:https://play.google.com/store/apps/details?id=com.usatolebanese');
  }

  void rateApp() {
    pop();

    LaunchReview.launch(androidAppId: Constants.packageName);
  }

  var collections = [
    'Lebanon Statics',
    'Syria Statics ',
  ];
  void navigateToChart() {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return ChartRoot(collections[index], aspectRatio);
      },
      transitionsBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return SlideTransition(
          position: new Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(animation),
          child: new SlideTransition(
            position: new Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(0.0, 1.0),
            ).animate(secondaryAnimation),
            child: child,
          ),
        );
      },
    ));
  }
}
