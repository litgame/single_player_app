import 'package:flutter/cupertino.dart';
import 'package:single_player_app/src/tools.dart';

enum MagicType {
  marionette,
  eurythmics,
  keyword,
  additionalEvent,
  // myTurn, // ??? Мой ход: ход незамедлительно переходит от Заколдованного к магу с сохранением выпавшей карты
  // nextTurn, // ??? Переход хода: ход Заколдованного заканчивается, начинается ход слудеющего игрока.
  cancelMagic,
}

extension MagicTypeExtension on MagicType {
  String translatedName(BuildContext context) {
    switch (this) {
      case MagicType.marionette:
        return context.loc().magicMarionetteTitle;

      case MagicType.eurythmics:
        return context.loc().magicEurythmicsTitle;

      case MagicType.keyword:
        return context.loc().magicKeywordTitle;

      case MagicType.additionalEvent:
        return context.loc().magicAdditionalEventTitle;

      case MagicType.cancelMagic:
        return context.loc().magicCancelTitle;
    }
  }

  MagicType fromName(String name) {
    switch (name) {
      case 'marionette':
        return MagicType.marionette;
      case 'eurythmics':
        return MagicType.eurythmics;
      case 'keyword':
        return MagicType.keyword;
      case 'additionalEvent':
        return MagicType.additionalEvent;
      case 'cancelMagic':
        return MagicType.cancelMagic;
    }
    throw ArgumentError('Invalid name: $name');
  }
}

class MagicItem {
  /// Марионетка/Предсказание: Маг указывает Заколдованному, что он должен будет сказать
  /// в свой ход
  ///
  /// В механике приложения игрок выбирает, через сколько ходов это должно
  /// произойти и вводит текст.
  /// После того как событие произошло - оно автоматически удаляется из списка
  /// влияющих на игру.
  /// Есть возможность отменить его до того как произойдёт -
  /// картой {MagicType.cancelMagic}
  ///
  /// В настольной версии этой карте больше соответствует карта "предсказание",
  /// но в мобильном приложении приходится планировать появление событий заранее.
  MagicItem.marionette(this.description, this.fireAfterTurns)
      : type = MagicType.marionette {
    _checkDescriptionFilled();
    _checkTurnsPositive();
  }

  /// Ритмика (N): каждые N ходов, начиная с Заколдованного, игрок должен
  /// использовать в рассказе слово или фразу, заданную Магом.
  ///
  /// В механике приложения игрок в свой ход настраивает, как и что должно
  /// происходить, после чего событие постоянно влияет на игру, пока его не
  /// отменят картой {MagicType.cancelMagic}
  MagicItem.eurythmics(this.description, this.fireAfterTurns)
      : type = MagicType.eurythmics,
        repeat = true {
    fireAfterTurnsOriginal = fireAfterTurns;
    _checkDescriptionFilled();
    _checkTurnsPositive();
  }

  /// Ключевое слово (N): Заколдованный должен N раз использоватьв своём
  /// рассказе слово или фразу, заданную Магом
  ///
  /// В механике приложения событие должно удаляться после того как произошло,
  /// либо может быть отменено картой {MagicType.cancelMagic} до того как
  /// случится
  MagicItem.keyword(this.description, this.fireAfterTurns, this.repeatCount)
      : type = MagicType.keyword {
    _checkDescriptionFilled();
    _checkTurnsPositive();
    if (repeatCount < 1) {
      throw ArgumentError(type, 'repeatCount');
    }
  }

  /// Событийная карточка: Заколдованныйберет ещё одну событийную карточку
  /// {CardType} тут всегда generic (событие), поэтому указывать отдельно не надо
  ///
  /// В механике игры событие удаляется после того как произошло, либо есть
  /// возможность отменить его картой {MagicType.cancelMagic}
  MagicItem.additionalEvent(this.fireAfterTurns)
      : type = MagicType.additionalEvent {
    _checkTurnsPositive();
  }

  /// Отмена магии: отмена любой магии, применённой в лбой момент клюбому игроку
  ///
  /// В механике приложения это событие должно выскакивать рандомно для любого
  /// пользователя, и только в свой ход он сможет выбрать наложенную на игру
  /// магию из списка и отменить какую-то одну.
  MagicItem.cancelMagic() : type = MagicType.cancelMagic;

  MagicType type;

  /// Через сколько ходов после текущего должнга сработать
  int fireAfterTurns = 0;
  int fireAfterTurnsOriginal = 0;

  /// Нужно ли по нескольку раз повторять указанное слово или фразу?
  int repeatCount = 1;

  /// Должно ли событие повторяться каждые N ходов (указаны в {fireAfterTurns}
  bool repeat = false;

  /// Слово или описание события или иное текстовое описание магического действия
  String description = '';

  void _checkTurnsPositive() {
    if (fireAfterTurns < 1) {
      throw ArgumentError(type, 'fireAfterTurns');
    }
  }

  void _checkDescriptionFilled() {
    if (description.isEmpty) {
      throw ArgumentError(type, 'description');
    }
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'fireAfterTurns': fireAfterTurns,
        'fireAfterTurnsOriginal': fireAfterTurnsOriginal,
        'repeatCount': repeatCount,
        'repeat': repeat,
        'description': description,
      };

  factory MagicItem.fromJson(Map<String, dynamic> json) {
    final strType = json['type'];
    if (strType == null) throw ArgumentError('Invalid json format');
    final type = MagicType.marionette.fromName(strType);
    final description = json['description'];
    final fireAfterTurns = json['fireAfterTurns'];

    if (description == null || fireAfterTurns == null) {
      throw ArgumentError('Invalid json format');
    }
    switch (type) {
      case MagicType.marionette:
        return MagicItem.marionette(description, fireAfterTurns);

      case MagicType.eurythmics:
        final fireAfterTurnsOriginal = json['fireAfterTurnsOriginal'];
        if (fireAfterTurnsOriginal == null) {
          throw ArgumentError('Invalid json format');
        }
        return MagicItem.eurythmics(description, fireAfterTurns)
          ..fireAfterTurnsOriginal = fireAfterTurnsOriginal;

      case MagicType.keyword:
        final repeatCount = json['repeatCount'];
        if (repeatCount == null) throw ArgumentError('Invalid json format');
        return MagicItem.keyword(description, fireAfterTurns, repeatCount);

      case MagicType.additionalEvent:
        return MagicItem.additionalEvent(fireAfterTurns);

      case MagicType.cancelMagic:
        return MagicItem.cancelMagic();
    }
  }
}
