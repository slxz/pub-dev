// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:meta/meta.dart';

import '_cache.dart';

/// Renders the `shared/detail/header.mustache` template
///
/// The like button in the header will not be displayed when [isLiked] is null.
String renderDetailHeader({
  @required String title,
  int packageLikes,
  bool isLiked,
  bool isFlutterFavorite = false,
  String metadataHtml,
  String tagsHtml,
  bool isPublisher = false,
}) {
  return templateCache.renderTemplate('shared/detail/header', {
    'title': title,
    'metadata_html': metadataHtml,
    'tags_html': tagsHtml,
    'is_publisher': isPublisher,
    'like_count': '$packageLikes ${packageLikes == 1 ? "like" : "likes"}',
    'is_liked': isLiked,
    'has_likes': isLiked != null,
    'is_flutter_favorite': isFlutterFavorite,
  });
}

/// Renders the `shared/detail/page.mustache` template
String renderDetailPage({
  @required String headerHtml,
  @required List<Tab> tabs,
  @required String infoBoxHtml,
  String footerHtml,
}) {
  return templateCache.renderTemplate('shared/detail/page', {
    'header_html': headerHtml,
    'tabs_html': renderDetailTabs(tabs),
    'info_box_html': infoBoxHtml,
    'footer_html': footerHtml,
  });
}

/// Renders the `views/shared/detail/tabs.mustache` template.
String renderDetailTabs(List<Tab> tabs) {
  // active: the first one with content
  for (Tab tab in tabs) {
    if (tab.contentHtml != null) {
      tab.isActive = true;
      break;
    }
  }
  final values = {'tabs': tabs.map((t) => t._toMustacheData()).toList()};
  return templateCache.renderTemplate('shared/detail/tabs', values);
}

/// Defines the header and content part of a tab.
class Tab {
  final String id;
  final String titleHtml;
  final String contentHtml;
  final bool isMarkdown;
  bool isActive = false;

  Tab.withContent({
    @required this.id,
    String title,
    String titleHtml,
    @required this.contentHtml,
    this.isMarkdown = false,
  }) : titleHtml = titleHtml ?? htmlEscape.convert(title);

  Tab.withLink({
    @required this.id,
    String title,
    String titleHtml,
    @required String href,
  })  : titleHtml =
            '<a href="$href">${titleHtml ?? htmlEscape.convert(title)}</a>',
        contentHtml = null,
        isMarkdown = false;

  Map _toMustacheData() {
    final titleClasses = <String>[
      contentHtml == null ? 'tab-link' : 'tab-button',
      if (isActive) '-active',
    ];
    final contentClasses = <String>[
      'tab-content',
      if (isActive) '-active',
      if (isMarkdown) 'markdown-body',
    ];
    return <String, dynamic>{
      'id': id,
      'title_classes': titleClasses.join(' '),
      'title_html': titleHtml,
      'content_classes': contentClasses.join(' '),
      'content_html': contentHtml,
      'has_content': contentHtml != null,
    };
  }
}
