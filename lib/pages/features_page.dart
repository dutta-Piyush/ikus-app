import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ikus_app/components/button_feature.dart';
import 'package:ikus_app/components/icon_text.dart';
import 'package:ikus_app/i18n/strings.g.dart';
import 'package:ikus_app/model/feature.dart';
import 'package:ikus_app/service/favorite_service.dart';
import 'package:ikus_app/utility/ui.dart';

class FeaturesPage extends StatefulWidget {
  @override
  _FeaturesPageState createState() => _FeaturesPageState();
}

class _FeaturesPageState extends State<FeaturesPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: OvguPixels.mainScreenPadding,
            child: IconText(
              size: OvguPixels.headerSize,
              distance: OvguPixels.headerDistance,
              icon: Icons.apps,
              text: t.main.features.title,
            ),
          ),
          SizedBox(height: 30),
          ...Feature.values.map((feature) => ButtonFeature(
            feature: feature,
            favorite: FavoriteService.isFavorite(feature),
            selectCallback: () {
              Navigator.push(context, CupertinoPageRoute(builder: (context) => feature.widget));
            },
            favoriteCallback: () {
              setState(() {
                FavoriteService.toggleFavorite(feature);
              });
            },
          ))
        ],
      ),
    );
  }
}