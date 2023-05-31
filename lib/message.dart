// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: require_trailing_commas

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../hojun/post_main_document.dart';

/// Message route arguments.
class MessageArguments {
  final RemoteMessage message;
  final bool openedApplication;
  MessageArguments(this.message, this.openedApplication);
}

/// Displays information about a [RemoteMessage].
class MessageView extends StatefulWidget {
  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  @override
  Widget build(BuildContext context) {
    final MessageArguments args =
    ModalRoute.of(context)!.settings.arguments! as MessageArguments;
    RemoteMessage message = args.message;
    return PostDocument(
      postId: message.data['postId'],
      imageUrl: message.data['imageUrl'],
      postMain: message.data['postMain'],
      userNickname: message.data['userNickname'],
      postName: message.data['postName'],
      userId: message.data['userId'],
      timestamp: Timestamp.now(),
      like: 0,
      address: message.data['address'],
      profile: "",
    );
  }
}