import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:ikus_app/components/badge.dart';
import 'package:ikus_app/components/main_list_view.dart';
import 'package:ikus_app/i18n/strings.g.dart';
import 'package:ikus_app/model/post.dart';
import 'package:ikus_app/utility/ui.dart';
import 'package:url_launcher/url_launcher.dart';

class PostScreen extends StatelessWidget {

  final Post post;

  const PostScreen(this.post);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OvguColor.primary,
        title: Text(t.post.title),
      ),
      body: MainListView(
        children: [
          SizedBox(height: 30),
          Padding(
            padding: OvguPixels.mainScreenPadding,
            child: Row(
              children: [
                Badge(text: post.channel.name),
                SizedBox(width: 10),
                Badge(text: post.formattedDate),
              ],
            ),
          ),
          SizedBox(height: 30),
          Padding(
            padding: OvguPixels.mainScreenPadding,
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(post.title, style: TextStyle(fontSize: OvguPixels.headerSize, fontWeight: FontWeight.bold))
            ),
          ),
          SizedBox(height: 30),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Html(
              data: post.content,
              style: {
                "body": Style(fontSize: FontSize.large), // make text bigger
              },
              onLinkTap: (url) async {
                await launch(url);
              },
            ),
          ),
          SizedBox(height: 30),
          if(post.images.length == 1)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 50),
              child: ClipRRect(
                  borderRadius: OvguPixels.borderRadiusImage,
                  child: post.images.first
              ),
            ),
          if(post.images.length > 1)
            CarouselSlider(
              options: CarouselOptions(
                  height: 500,
                  viewportFraction: 0.8,
                  autoPlay: true,
              ),
              items: post.images.map((image) {
                return Builder(
                  builder: (BuildContext context) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                          borderRadius: OvguPixels.borderRadiusImage,
                          child: image
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          SizedBox(height: 50)
        ],
      ),
    );
  }
}
