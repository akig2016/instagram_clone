import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../models/user.dart' as model;
import '../providers/user_provider.dart';
import '../resources/firestore_methods.dart';
import '../screens/comments_screen.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import 'like_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final _screenshotController = ScreenshotController();
  int commentLen = 0;
  bool isLikeAnimating = false;

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
    setState(() {});
  }

  deletePost(String postId) async {
    try {
      await FireStoreMethods().deletePost(postId);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;
    //if (user) {}
    final width = MediaQuery.of(context).size.width;

    return Container(
      // boundary needed for web

      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      //color: Colors.white,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // HEADER SECTION OF THE POST
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 16,
              ).copyWith(right: 0),
              child: Row(
                children: <Widget>[
                  InkWell(
                    child: CircleAvatar(
                      radius: 23,
                      backgroundImage: CachedNetworkImageProvider(
                        widget.snap['profImage'].toString(),
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          uid: widget.snap['uid'],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.snap['username'].toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Text(
                          DateFormat.yMMMd()
                              .format(widget.snap['datePublished'].toDate()),
                          style: const TextStyle(
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  widget.snap['uid'].toString() == user.uid
                      ? IconButton(
                          onPressed: () {
                            showDialog(
                              useRootNavigator: false,
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: ListView(
                                      padding: const EdgeInsets.only(left: 16),
                                      shrinkWrap: true,
                                      children: [
                                        'Delete',
                                      ]
                                          .map(
                                            (e) => InkWell(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 12,
                                                      horizontal: 16),
                                                  child: Text(e),
                                                ),
                                                onTap: () {
                                                  deletePost(
                                                    widget.snap['postId']
                                                        .toString(),
                                                  );
                                                  // remove the dialog box
                                                  Navigator.of(context).pop();
                                                }),
                                          )
                                          .toList()),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.more_vert),
                        )
                      : Container(),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // IMAGE SECTION OF THE POST
            GestureDetector(
              onDoubleTap: () {
                FireStoreMethods().likePost(
                  widget.snap['postId'].toString(),
                  user.uid,
                  widget.snap['likes'],
                );
                setState(() {
                  isLikeAnimating = true;
                });
              },
              child: Card(
                elevation: 5,
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      width: double.infinity,
                      child: Image(
                        image: CachedNetworkImageProvider(
                            widget.snap['postUrl'].toString()),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(
                      widget.snap['description'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          backgroundColor: Color.fromARGB(30, 0, 0, 0)),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isLikeAnimating ? 1 : 0,
                      child: LikeAnimation(
                        isAnimating: isLikeAnimating,
                        duration: const Duration(
                          milliseconds: 400,
                        ),
                        onEnd: () {
                          setState(() {
                            isLikeAnimating = false;
                          });
                        },
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // LIKE, COMMENT SECTION OF THE POST
            Row(
              children: <Widget>[
                LikeAnimation(
                  isAnimating: widget.snap['likes'].contains(user.uid),
                  smallLike: true,
                  child: IconButton(
                    icon: widget.snap['likes'].contains(user.uid)
                        ? const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        : const Icon(
                            Icons.favorite_border,
                          ),
                    onPressed: () => FireStoreMethods().likePost(
                      widget.snap['postId'].toString(),
                      user.uid,
                      widget.snap['likes'],
                    ),
                  ),
                ),
                Text(
                  '${widget.snap['likes'].length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.comment_outlined,
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                        postId: widget.snap['postId'].toString(),
                      ),
                    ),
                  ),
                ),
                Text(
                  '$commentLen',
                  style: const TextStyle(
                    fontSize: 16,
                    color: secondaryColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.share,
                  ),
                  onPressed: _takeScreenshot,
                ),
                Expanded(
                    child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                      icon: const Icon(Icons.bookmark_border),
                      onPressed: () {}),
                ))
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _takeScreenshot() async {
    final imageFile = await _screenshotController.captureFromWidget(
      Card(
        elevation: 5,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              width: double.infinity,
              child: Image.network(
                widget.snap['postUrl'].toString(),
                fit: BoxFit.cover,
              ),
            ),
            Text(
              widget.snap['description'],
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  backgroundColor: Color.fromARGB(30, 0, 0, 0)),
            ),
          ],
        ),
      ),
    );
    print("ScreenShot--------" + imageFile.toString());
    Share.shareXFiles(
      [
        XFile.fromData(
          imageFile,
          name: 'flutter_logo.png',
          mimeType: 'image/png',
        ),
      ],
      text: "My First share",
    );
  }
}
