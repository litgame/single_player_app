part of '../game_screen.dart';

class RestorableDisplayedCards extends RestorableValue<List<lit_card.Card>> {
  @override
  List<lit_card.Card> createDefaultValue() => <lit_card.Card>[];

  @override
  void didUpdateValue(List<lit_card.Card>? oldValue) {
    Function eq = const ListEquality(ListCardEquality()).equals;
    if (oldValue == null || !eq(oldValue, value)) {
      notifyListeners();
    }
  }

  @override
  List<lit_card.Card> fromPrimitives(Object? data) {
    if (data != null && data is List) {
      return data.map<lit_card.Card>((nameAndImage) {
        nameAndImage as String;
        final parts = nameAndImage.split('|');
        final card = lit_card.Card.clone();
        card['name'] = parts.first;
        card['imgUrl'] = parts.last;
        return card;
      }).toList();
    }
    return createDefaultValue();
  }

  @override
  Object toPrimitives() => value.map((e) => e.name + '|' + e.imgUrl).toList();
}

class ListCardEquality implements Equality<lit_card.Card> {
  const ListCardEquality();

  @override
  bool equals(lit_card.Card e1, lit_card.Card e2) => e1.imgUrl == e2.imgUrl;

  @override
  int hash(lit_card.Card e) => e.hashCode;

  @override
  bool isValidKey(Object? o) => o is lit_card.Card;
}
