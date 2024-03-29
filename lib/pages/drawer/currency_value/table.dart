import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:usatolebanese/base/logic.dart';
import 'package:usatolebanese/utility/localization/localization.dart';

class Tabl extends StatelessWidget {
  Map<String, dynamic> data;
  Tabl(this.data);
  @override
  Widget build(BuildContext context) {
    var localization = Localization.of(context).globals;
    var baseLogic = Provider.of<BaseLogic>(context, listen: false);
    var textTheme = Theme.of(context).textTheme;
    num aspectRatio = baseLogic.aspectRatio;
    double height = (MediaQuery.of(context).size.height);
    bool bigScreenSize = height >= 792;

    var logic = Provider.of<BaseLogic>(context);
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        SizedBox.fromSize(
            size: Size.fromHeight(baseLogic.aspectRatio * 233),
            child: Row(
              children: <Widget>[
//            Column(
//              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//              children: <Widget>[
//                Text(''),
//                Text(localization[0], style: textTheme.caption),
//                Text(localization[1], style: textTheme.caption),
//              ],
//            ),
                Spacer(
                  flex: 1,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          localization[2],
                          style: textTheme.caption,
                        ),
                        SlideTransition(
                          child: logic.icon('buy', data),
                          position: logic.animation,
                        )
                      ],
                    ),
//                Text(
//                  data['buy']['from'].toString(),
//                  style: textTheme.title,
//                ),
                    Text(
                      data['buy']['to'].toString(),
                      style: textTheme.title,
                    ),
                    bigScreenSize
                        ? Container()
                        : ScaleTransition(
                            scale: logic.scaleAnimation,
                            child: SizedBox(
                              width: 128,
                              height: 30,
                              child: RaisedButton.icon(
                                  color: Colors.red,
                                  hoverColor:  Colors.white,
                                  onPressed: () {
                                    logic.shareApp();
                                  },
                                  icon: Icon(FontAwesomeIcons.share,size: 14,color: Colors.white,),
                                  label: Text(
                                    localization[6],
                                    style: textTheme.caption,
                                  )),
                            ),
                          ),
                  ],
                ),
                Spacer(
                  flex: 3,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(localization[3], style: textTheme.caption),
                        SlideTransition(
                          child: logic.icon('sell', this.data),
                          position: logic.animation,
                        )
                      ],
                    ),


//                Text(
//                  data['sell']['from'].toString(),
//                  style: textTheme.title,
//                ),
                    Text(
                      data['sell']['to'].toString(),
                      style: textTheme.title,
                    ),
                    bigScreenSize
                        ? Container()
                        : ScaleTransition(
                            scale: logic.scaleAnimation,
                            child: SizedBox(
                              width: 124,
                              height: 30,
                              child: RaisedButton.icon(
                                  color: Colors.red,

                                  onPressed: () {
                                    logic.navigateToChart();
                                  },
                                  icon: Icon(FontAwesomeIcons.calendar,size: 14,color: Colors.white,),
                                  label: Text(
                                    localization[7],
                                    style: textTheme.caption,
                                  )),

                            ),


                          ),

                  ],
                ),
                Spacer(
                  flex: 1,
                ),
              ],
            )),

      ],
    );
  }
}
