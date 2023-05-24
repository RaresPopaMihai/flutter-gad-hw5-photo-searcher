import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/index.dart';
import 'containers/index.dart';

class PictureDetails extends StatelessWidget {
  const PictureDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return SelectedPictureContainer(
      builder: (BuildContext context, Picture picture) {
        return Scaffold(
          appBar: AppBar(
            title: Text(picture.user.name),
            actions: <Widget>[
              CircleAvatar(
                foregroundImage: CachedNetworkImageProvider(picture.user.profileImage.small),
              ),
              const SizedBox(
                width: 10,
                height: 10,
              ),
            ],
          ),
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[CachedNetworkImage(
              imageUrl: picture.urls.regular,
              fit: BoxFit.fill,
              ),
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: ListTile(
                  title: Row(
                    children: <Widget>
                    [
                      const SizedBox(width: 5,),
                      const Icon(
                        Icons.thumb_up_sharp,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(width: 5,),
                      Text(picture.likes.toString())
                    ],
                  ),
                  trailing: Container(
                    margin: const EdgeInsets.only(right: 5),
                      child: Text('Created at: ${picture.createdAt.day}.${picture.createdAt.month}.${picture.createdAt.year}')),
                ),
              )
            ]
          ),
        );
      },
    );
  }
}
