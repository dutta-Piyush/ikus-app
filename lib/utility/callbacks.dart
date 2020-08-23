
import 'package:ikus_app/model/channel.dart';
import 'package:ikus_app/model/post.dart';

typedef void Callback();
typedef void IntCallback(int integer);
typedef void BoolCallback(bool boolean);
typedef void PostCallback(Post post);
typedef Future<void> ChannelBooleanCallback(Channel channel, bool boolean);