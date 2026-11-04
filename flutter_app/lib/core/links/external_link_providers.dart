import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/core/links/external_link_service.dart';

final externalLinkServiceProvider = Provider<ExternalLinkService>((ref) {
  return const UrlLauncherExternalLinkService();
});
