import 'package:flutter/material.dart';
//import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/routes/app_pages.dart';
import 'app/utils/network/network_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // Ensure GetStorage is initialized before running the app
  //await FlutterDownloader.initialize();  // Initialize flutter_downloader here
  Get.put(NetworkManager());



  runApp(
    GetMaterialApp(
      title: "Immigration and Citizenship Service - ETHIOPIA",
      initialRoute: Routes.SPLASH, // Ensure this points to the splash screen
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
    ),
  );
}
