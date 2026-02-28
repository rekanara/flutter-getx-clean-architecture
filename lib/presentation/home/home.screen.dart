import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:zidanfath_codebase/components/atoms/custom_button.dart';
import 'package:zidanfath_codebase/components/atoms/custom_text.dart';
import 'package:zidanfath_codebase/infrastructure/navigation/routes.dart';
import 'package:zidanfath_codebase/utils/config.dart';
import 'package:zidanfath_codebase/components/molecules/custom_cached_image.dart';

import 'package:chucker_flutter/chucker_flutter.dart';

import '../../utils/helper/dialog.dart';
import '../../utils/helper/snackbar.dart';
import 'controllers/home.controller.dart';
import 'widgets/banner_carousel.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('HomeScreen'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Banner Carousel
              Obx(() {
                if (controller.banners.isEmpty) {
                  return const SizedBox.shrink();
                }
                return BannerCarousel(banners: controller.banners);
              }),
              const SizedBox(height: 16),

              /// Login
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                tileColor: Colors.grey[200],
                leading: const Icon(Icons.login),
                title: CustomText(text: 'Login', fontType: FontType.bodyLarge),
                trailing: CustomButton(
                  title: 'Login',
                  onPressed: () {
                    Get.toNamed(Routes.login);
                  },
                ),
              ),
              const SizedBox(height: 8),

              /// Chucker
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                tileColor: Colors.grey[200],
                leading: Icon(Icons.bug_report, color: theme.colorScheme.error),
                title: CustomText(
                  text: 'Chucker',
                  fontType: FontType.bodyLarge,
                  color: theme.colorScheme.error,
                ),
                trailing: ChuckerFlutter.chuckerButton,
              ),
              const SizedBox(height: 8),

              /// ExpansionTile snackbar
              ExpansionTile(
                title: CustomText(
                  text: 'Snackbar',
                  fontType: FontType.bodyLarge,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                collapsedBackgroundColor: Colors.grey[200],
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                backgroundColor: Colors.grey[200],

                leading: Icon(Icons.signal_cellular_alt, color: ColorData.info),

                children: [
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    tileColor: Colors.grey[200],
                    leading: Icon(Icons.check_circle, color: ColorData.success),
                    title: CustomText(
                      text: 'Snackbar Success',
                      fontType: FontType.bodyLarge,
                      color: ColorData.success,
                    ),
                    trailing: CustomButton(
                      title: 'Open',
                      color: ColorData.success,
                      onPressed: () {
                        SnackbarHelper.showSuccess('Snackbar');
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    tileColor: Colors.grey[200],
                    leading: Icon(Icons.error, color: ColorData.error),
                    title: CustomText(
                      text: 'Snackbar Error',
                      fontType: FontType.bodyLarge,
                      color: ColorData.error,
                    ),
                    trailing: CustomButton(
                      title: 'Open',
                      color: ColorData.error,
                      onPressed: () {
                        SnackbarHelper.showError('Snackbar');
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    tileColor: Colors.grey[200],
                    leading: Icon(Icons.warning, color: ColorData.warning),
                    title: CustomText(
                      text: 'Snackbar Warning',
                      fontType: FontType.bodyLarge,
                      color: ColorData.warning,
                    ),
                    trailing: CustomButton(
                      title: 'Open',
                      color: ColorData.warning,
                      onPressed: () {
                        SnackbarHelper.showWarning('Snackbar');
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    tileColor: Colors.grey[200],
                    leading: Icon(Icons.info, color: ColorData.info),
                    title: CustomText(
                      text: 'Snackbar Info',
                      fontType: FontType.bodyLarge,
                      color: ColorData.info,
                    ),
                    trailing: CustomButton(
                      title: 'Open',
                      color: ColorData.info,
                      onPressed: () {
                        SnackbarHelper.showInfo('Snackbar');
                      },
                    ),
                  ),

                  /// snackbar Top
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    tileColor: Colors.grey[200],
                    leading: Icon(Icons.info, color: ColorData.info),
                    title: CustomText(
                      text: 'Snackbar Top',
                      fontType: FontType.bodyLarge,
                      color: ColorData.info,
                    ),
                    trailing: CustomButton(
                      title: 'Open',
                      color: ColorData.info,
                      onPressed: () {
                        SnackbarHelper.show(
                          status: SnackStatus.success,
                          title: 'Snackbar Custom',
                          message: 'Snackbar Custom',
                          position: SnackPosition.TOP,
                          duration: 3,
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// Cached Network Image
              ExpansionTile(
                title: CustomText(
                  text: 'Cached Image',
                  fontType: FontType.bodyLarge,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                collapsedBackgroundColor: Colors.grey[200],
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                backgroundColor: Colors.grey[200],
                leading: Icon(Icons.image, color: theme.colorScheme.primary),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const CustomCachedImage(
                          imageUrl: 'https://picsum.photos/400/200',
                          width: double.infinity,
                          height: 200,
                          borderRadius: 16,
                        ),
                        const SizedBox(height: 16),
                        CustomText(
                          text:
                              'Gambar di atas di-load dari internet secara asinkron dan otomatis di-cache ke dalam penyimpanan lokal menggunakan cached_network_image.',
                          fontType: FontType.bodyMedium,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// Dialog
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                tileColor: Colors.grey[200],
                leading: Icon(Icons.info, color: ColorData.info),
                title: CustomText(
                  text: 'Dialog',
                  fontType: FontType.bodyLarge,
                  color: ColorData.info,
                ),
                trailing: CustomButton(
                  title: 'Open',
                  onPressed: () {
                    DialogHelper.showDialog(
                      title: 'Dialog',
                      message: 'Dialog',
                      onSubmit: () {
                        Get.back();
                      },
                      onCancel: () {
                        Get.back();
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              /// Responsive
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                tileColor: Colors.grey[200],
                leading: Icon(Icons.screen_share, color: ColorData.info),
                title: CustomText(
                  text: 'Responsive',
                  fontType: FontType.bodyLarge,
                  color: ColorData.info,
                ),
                trailing: CustomButton(
                  title: 'Open',
                  onPressed: () {
                    Get.toNamed(Routes.user);
                  },
                ),
              ),

              const SizedBox(height: 8),

              /// GetBuilder
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                tileColor: Colors.grey[200],
                leading: Icon(Icons.screen_share, color: ColorData.info),
                title: CustomText(
                  text: 'GetBuilder',
                  fontType: FontType.bodyLarge,
                  color: ColorData.info,
                ),
                trailing: CustomButton(
                  title: 'Open',
                  onPressed: () {
                    Get.toNamed(Routes.user);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
