import 'package:get/get.dart';

import '../../../../domain/contacts/repositories/contacts_repository.dart';
import '../../../../domain/contacts/usecases/get_contacts_usecase.dart';
import '../../../../infrastructure/dal/contacts/repositories/contacts_repository_impl.dart';
import '../../../../infrastructure/dal/services/contacts_api_service.dart';
import '../../../../presentation/contacts/controllers/contacts.controller.dart';

class ContactsControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ContactsApiService>(() => ContactsApiService());
    Get.lazyPut<ContactsRepository>(
      () => ContactsRepositoryImpl(apiService: Get.find()),
    );
    Get.lazyPut<GetContactsUseCase>(() => GetContactsUseCase(Get.find()));

    Get.lazyPut<ContactsController>(
      () => ContactsController(getContactsUseCase: Get.find()),
    );
  }
}
