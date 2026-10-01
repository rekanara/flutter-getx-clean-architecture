import 'package:get/get.dart';

import 'en_us.dart';
import 'id_id.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en_US': enUS, 'id_ID': idID};
}
