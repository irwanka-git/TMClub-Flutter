import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/BlogController.dart';
import 'package:tmcapp/controller/EventController.dart';
import 'package:tmcapp/controller/SearchController.dart';
import 'package:tmcapp/model/list_id.dart';

class CustomSearchDelegate extends SearchDelegate {
  CustomSearchDelegate({required this.lookupController});

  // Demo list to show querying
  final SearchController lookupController;
  final BlogController blogController = BlogController.to;
  final EventController eventController = EventController.to;
  // List  searchTerms =  <SearchItem>[].obs;

  // first overwrite to
  // clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  // second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  // third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    List<SearchItem> matchQuery = [];
    for (var item in lookupController.ListItem.value) {
      if (item.title.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(item);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return buildTileItem(result);
      },
    );
  }

  // last overwrite to show the
  // querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    List<SearchItem> matchQuery = [];
    for (var item in lookupController.ListItem.value) {
      if (item.title.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(item);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return buildTileItem(result);
      },
    );
  }

  Widget buildTileItem(SearchItem result) {
    return InkWell(
      onTap: () {
        if (lookupController.resourceModel.value == "blog") {
          blogController.openScreenItem(result.id);
        }
        if (lookupController.resourceModel.value == "event") {
          eventController.openScreenItem(result.id);
        }
      },
      child: GFListTile(
        avatar: GFAvatar(
          radius: 20,
          backgroundImage: NetworkImage(result.avatar),
        ),
        titleText: result.title,
        subTitleText: result.subtitle,
      ),
    );
  }
}
