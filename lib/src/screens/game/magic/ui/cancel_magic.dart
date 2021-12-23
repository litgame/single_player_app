import 'package:flutter/material.dart';
import 'package:single_player_app/src/screens/game/magic/ui/ui_type.dart';
import 'package:single_player_app/src/services/magic_service/magic_item.dart';
import 'package:single_player_app/src/services/magic_service/magic_service.dart';
import 'package:single_player_app/src/tools.dart';

class UITypeCancelMagic extends UITypeBase {
  UITypeCancelMagic(MagicType type, this.service) : super(type);

  var fireAfterTurns = 1;
  final MagicService service;

  @override
  List<Widget> build(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: Text(
          context.loc().magicCancelDescription,
          style: const TextStyle(fontSize: 18),
        ),
      ),
      _CancelWidget(
        parent: this,
      )
    ];
  }

  @override
  MagicItem getMagicItem() => MagicItem.cancelMagic();
}

class _ExpandableItem {
  _ExpandableItem(this.magicItem);

  bool isExpanded = false;
  final MagicItem magicItem;
}

class _CancelWidget extends StatefulWidget {
  const _CancelWidget({Key? key, required this.parent}) : super(key: key);

  final UITypeCancelMagic parent;

  @override
  _CancelWidgetState createState() => _CancelWidgetState();
}

class _CancelWidgetState extends State<_CancelWidget> {
  late List<_ExpandableItem> items;

  @override
  void initState() {
    super.initState();
    items =
        widget.parent.service.allMagic.map((e) => _ExpandableItem(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sections = items.map((listItem) {
      final magicElement = listItem.magicItem;
      final columnWidgets = <Widget>[];
      columnWidgets.add(ListTile(
        title: Text(context.loc().magicModalTurns),
        trailing: Text(magicElement.fireAfterTurns.toString()),
      ));
      if (magicElement.type != MagicType.additionalEvent) {
        if (magicElement.type == MagicType.keyword) {
          columnWidgets.add(ListTile(
            title: Text(context.loc().magicKeywordRepeats),
            trailing: Text(magicElement.repeatCount.toString()),
          ));
        }
        columnWidgets.add(ListTile(
          title: Text(context.loc().magicDescriptionAbstract),
          trailing: Text(magicElement.description),
        ));
      }
      columnWidgets.add(ListTile(
        tileColor: const Color.fromRGBO(255, 0, 0, 0.07),
        title: Text(context.loc().magicDelete),
        subtitle: Text(context.loc().magicDeleteDescription),
        trailing: IconButton(
            onPressed: () {
              widget.parent.service.allMagic.remove(magicElement);
              Navigator.of(context).pop(widget.parent.getMagicItem());
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            )),
      ));
      return ExpansionPanel(
          isExpanded: listItem.isExpanded,
          headerBuilder: (BuildContext context, bool isExpanded) => ListTile(
                title: Text(magicElement.type.translatedName(context)),
              ),
          body: Column(
            children: columnWidgets,
          ));
    }).toList();

    return ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            items[index].isExpanded = !isExpanded;
          });
        },
        children: sections);
  }
}
