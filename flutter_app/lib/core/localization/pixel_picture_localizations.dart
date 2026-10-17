import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_template.dart';

String localizedPixelFigureName(
  AppLocalizations localizations,
  PixelPictureTemplate template,
) =>
    localizations.localeName.startsWith('tr')
        ? template.turkishName
        : template.englishName;
