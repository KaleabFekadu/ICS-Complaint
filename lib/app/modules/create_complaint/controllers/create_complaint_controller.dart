import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:device_info_plus/device_info_plus.dart';
import '../../../utils/constants/config.dart';
import 'dart:convert';
import 'package:clipboard/clipboard.dart';

import '../../qrscanner/controllers/qrscanner_controller.dart';

class CreateComplaintController extends GetxController {
  var selectedBranchId = ''.obs;
  var selectedServiceId = ''.obs;
  var ticketNumber = ''.obs;
  var firstName = ''.obs;
  var lastName = ''.obs;
  var surname = ''.obs;
  var detail = ''.obs;
  var hasDocument = false.obs;
  var files = <PlatformFile>[].obs;
  var links = <String>[].obs;
  var currentStep = 0.obs;
  final ticketNumberController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final surnameController = TextEditingController();
  var isLoadingBranches = false.obs;
  var isLoadingServices = false.obs;
  final _formKey = GlobalKey<FormState>();
  final branches = <Map<String, dynamic>>[].obs;
  final services = <Map<String, dynamic>>[].obs;
  var ticketInfo = <String, dynamic>{}.obs;
  var isTicketVerified = false.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isFilePickerActive = false.obs;
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  var isRecording = false.obs;
  var recordingPath = ''.obs;
  var recordingDuration = Duration.zero.obs;
  Timer? _recordingTimer;
  String? childCategoryId;
  String? categoryId;
  var categoryName = ''.obs;
  var selectedTab = 0.obs;
  RxBool contactMe = false.obs;
  Rx<DateTime?> incidentTime = Rx<DateTime?>(null);
  RxString incidentPlace = ''.obs;
  final descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  // New field for staff information from QR code
  var staffInfo = <String, dynamic>{}.obs;

  static const int maxFileSize = 500 * 1024 * 1024; // 500MB in bytes
  static const int maxFileCount = 5;
  static const List<String> allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'mp4',
    'mov',
    'avi',
    'mp3',
    'wav',
    'm4a',
    'aac',
    'pdf',
    'doc',
    'docx'
  ];
  static const List<String> backendAllowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'mp4',
    'mp3',
    'wav',
    'pdf',
    'doc',
    'docx'
  ];

  String get formattedTime {
    if (incidentTime.value == null) return 'Select Time';
    return DateFormat('MMM d, yyyy - HH:mm').format(incidentTime.value!);
  }

  final tabs = [
    UploadTab(
      icon: Iconsax.camera,
      uploadTitle: 'Photo Upload',
      actions: [
        UploadAction(Iconsax.camera, 'Take Photo'),
        UploadAction(Iconsax.gallery, 'Gallery'),
      ],
    ),
    UploadTab(
      icon: Iconsax.video,
      uploadTitle: 'Video Upload',
      actions: [
        UploadAction(Iconsax.video, 'Take Video'),
        UploadAction(Iconsax.gallery, 'Gallery'),
      ],
    ),
    UploadTab(
      icon: Iconsax.microphone,
      uploadTitle: 'Audio Upload',
      actions: [
        UploadAction(Iconsax.microphone, 'Start Recording'),
        UploadAction(Iconsax.document, 'Pick From Files'),
      ],
    ),
    UploadTab(
      icon: Iconsax.document,
      uploadTitle: 'File Upload',
      actions: [
        UploadAction(Iconsax.document_upload, 'Insert File'),
      ],
    ),
  ];

  @override
  void onInit() async {
    super.onInit();
    fetchBranches();
    resetForm();

    final args = Get.arguments as Map<String, dynamic>?;
    childCategoryId = args?['child_category'] as String?;
    categoryId = args?['category'] as String?;
    categoryName.value =
        args?['category_name'] as String? ?? 'Unknown Category';

    ticketNumberController.text = ticketNumber.value;
    firstNameController.text = firstName.value;
    lastNameController.text = lastName.value;
    surnameController.text = surname.value;
    descriptionController.text = detail.value;

    ticketNumberController
        .addListener(() => ticketNumber.value = ticketNumberController.text);
    firstNameController
        .addListener(() => firstName.value = firstNameController.text);
    lastNameController
        .addListener(() => lastName.value = lastNameController.text);
    surnameController.addListener(() => surname.value = surnameController.text);
    descriptionController
        .addListener(() => detail.value = descriptionController.text);

    await _initAudioRecorder();
    await _initAudioPlayer();

    // Check for scanned QR code and fetch staff info
    final qrController = Get.find<QrscannerController>();
    if (qrController.scannedCode.isNotEmpty) {
      await fetchStaffInfo(qrController.scannedCode.value);
    }
  }

  Future<void> fetchStaffInfo(String staffId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please log in to fetch staff information.'.tr;
        Get.offAllNamed('/login');
        return;
      }

      final client = GraphQLClient(
        link: HttpLink(
          '${Config.baseUrl}/graphql',
          defaultHeaders: {'Authorization': 'Bearer $token'},
          httpClient: http.Client(),
        ),
        cache: GraphQLCache(),
      );

      const query = r'''
      query GetStaffMember($id: ID!) {
        staff_member(id: $id) {
          id
          name
          email
          phone_number
          position
          is_active
          branch {
            id
            name
            code
            description
          }
          service {
            id
            name
            description
          }
          complaintReports {
            id
            description
            status
            created_at
          }
          created_at
          updated_at
        }
      }
    ''';

      final result = await client
          .query(
        QueryOptions(
          document: gql(query),
          variables: {'id': staffId},
          fetchPolicy: FetchPolicy.networkOnly,
          errorPolicy: ErrorPolicy.all,
        ),
      )
          .timeout(Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('Request timed out after 15 seconds');
      });

      if (result.hasException) {
        print('GraphQL Error: ${result.exception.toString()}');
        errorMessage.value =
            'Failed to load staff information: ${result.exception.toString()}'
                .tr;
        return;
      }

      final data = result.data?['staff_member'] as Map<String, dynamic>?;
      if (data != null) {
        staffInfo.value = data;
        selectedBranchId.value = data['branch']?['id']?.toString() ?? '';
        selectedServiceId.value = data['service']?['id']?.toString() ?? '';
        ticketNumber.value = data['id']?.toString() ?? '';
        Get.snackbar(
          'Success'.tr,
          'Staff information loaded successfully!'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 2),
        );
      } else {
        errorMessage.value = 'Staff member not found.'.tr;
        staffInfo.clear();
      }
    } catch (e) {
      print('Fetch Staff Info Error: $e');
      errorMessage.value = 'Error fetching staff information: $e'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  void clearStaffInfo() {
    staffInfo.clear();
    selectedBranchId.value = '';
    selectedServiceId.value = '';
    ticketNumber.value = '';
    errorMessage.value = '';
  }

  // Modify resetForm() to include new properties
  void resetForm() {
    ticketNumber.value = '';
    firstName.value = '';
    lastName.value = '';
    surname.value = '';
    detail.value = '';
    hasDocument.value = false;
    files.clear();
    links.clear();
    currentStep.value = 0;
    ticketInfo.clear();
    isTicketVerified.value = false;
    isLoading.value = false;
    errorMessage.value = '';
    incidentTime.value = null;
    incidentPlace.value = '';
    contactMe.value = false;
    clearRecordings();
    staffInfo.clear();
    ticketNumberController.clear();
    firstNameController.clear();
    lastNameController.clear();
    surnameController.clear();
    descriptionController.clear();
  }

  Future<void> fetchBranches() async {
    isLoadingBranches.value = true;
    errorMessage.value = '';
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please log in to fetch branches.'.tr;
        Get.offAllNamed('/login');
        return;
      }

      final client = GraphQLClient(
        link: HttpLink(
          '${Config.baseUrl}/graphql',
          defaultHeaders: {'Authorization': 'Bearer $token'},
          httpClient: http.Client(),
        ),
        cache: GraphQLCache(),
      );

      const query = r'''
    query GetAllBranchesWithServices {
      all_branches {
        id
        name
        code
        description
        icon
        services {
          id
          name
          description
          draft
        }
      }
    }
  ''';

      final result = await client
          .query(
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.networkOnly,
          errorPolicy: ErrorPolicy.all,
        ),
      )
          .timeout(Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('Request timed out after 15 seconds');
      });

      if (result.hasException) {
        print('GraphQL Error Details: ${result.exception.toString()}');
        errorMessage.value =
            'Failed to load branches: ${result.exception.toString()}'.tr;
        return;
      }

      final data = result.data?['all_branches'] as List<dynamic>?;
      if (data != null && data.isNotEmpty) {
        branches.assignAll(data.cast<Map<String, dynamic>>().map((branch) {
          return {
            'id': branch['id']?.toString() ?? '',
            'name': branch['name']?.toString() ?? 'Unnamed Branch',
            'code': branch['code']?.toString() ?? '',
            'description': branch['description']?.toString() ?? '',
            'icon': branch['icon']?.toString() ?? '',
            'services': (branch['services'] as List<dynamic>?)
                    ?.cast<Map<String, dynamic>>() ??
                [],
          };
        }).toList());
        if (staffInfo.isEmpty) {
          services.clear();
          selectedBranchId.value = '';
          selectedServiceId.value = '';
        }
      } else {
        errorMessage.value = 'No branches found.'.tr;
      }
    } catch (e) {
      print('Fetch Branches Error: $e');
      errorMessage.value = 'Error fetching branches: $e'.tr;
    } finally {
      isLoadingBranches.value = false;
    }
  }

  Future<void> fetchServicesForBranch(String branchId) async {
    if (branchId.isEmpty) {
      services.clear();
      selectedServiceId.value = '';
      return;
    }

    isLoadingServices.value = true;
    errorMessage.value = '';
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please log in to fetch services.'.tr;
        Get.offAllNamed('/login');
        return;
      }

      final client = GraphQLClient(
        link: HttpLink(
          '${Config.baseUrl}/graphql',
          defaultHeaders: {'Authorization': 'Bearer $token'},
        ),
        cache: GraphQLCache(),
      );

      const query = r'''
      query GetBranchWithServices($branchId: ID!) {
        branch(id: $branchId) {
          id
          name
          services {
            id
            name
            description
            draft
          }
        }
      }
    ''';

      final result = await client.query(
        QueryOptions(
          document: gql(query),
          variables: {'branchId': branchId},
          fetchPolicy: FetchPolicy.networkOnly,
          errorPolicy: ErrorPolicy.all,
        ),
      );

      if (result.hasException) {
        print('GraphQL Error: ${result.exception.toString()}');
        errorMessage.value =
            'Failed to load services: ${result.exception.toString()}'.tr;
        return;
      }

      final data = result.data?['branch'] as Map<String, dynamic>?;
      if (data != null && data['services'] != null) {
        services.assignAll((data['services'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .where((service) => !(service['draft'] ?? false))
            .map((service) {
          return {
            'id': service['id']?.toString() ?? '',
            'name': service['name']?.toString() ?? 'Unnamed Service',
            'description': service['description']?.toString() ?? '',
            'draft': service['draft'] ?? false,
          };
        }).toList());
        if (staffInfo.isEmpty) {
          selectedServiceId.value = '';
        }
      } else {
        errorMessage.value = 'No services found for this branch.'.tr;
        services.clear();
      }
    } catch (e) {
      print('Fetch Services Error: $e');
      errorMessage.value = 'Error fetching services: $e'.tr;
    } finally {
      isLoadingServices.value = false;
    }
  }

  void nextStep() {
    errorMessage.value = '';
    final qrController = Get.find<QrscannerController>();
    if (currentStep.value == 0) {
      if (qrController.scannedCode.isNotEmpty && staffInfo.isNotEmpty) {
        // QR code scanned and staff info available
      } else if (selectedBranchId.value.isEmpty) {
        errorMessage.value = 'Please select a branch.'.tr;
        return;
      } else if (selectedServiceId.value.isEmpty) {
        errorMessage.value = 'Please select a service.'.tr;
        return;
      }
    } else if (currentStep.value == 2 && detail.isEmpty) {
      errorMessage.value = 'Please provide report details.'.tr;
      return;
    }
    if (currentStep.value < 3) {
      currentStep.value++;
    }
  }

  Future<void> _initAudioRecorder() async {
    try {
      await _audioRecorder.openRecorder();
      // Don't set subscription duration here - it's not needed for basic recording
      if (!await _audioRecorder.isEncoderSupported(Codec.aacADTS)) {
        print('AAC ADTS not supported, trying default codec');
      }
    } catch (e) {
      print('Error initializing audio recorder: $e');
      errorMessage.value = 'Failed to initialize audio recorder';
    }
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.openPlayer();
    } catch (e) {
      print('Error initializing audio player: $e');
      errorMessage.value = 'Failed to initialize audio player';
    }
  }

  @override
  void onClose() {
    ticketNumberController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    surnameController.dispose();
    descriptionController.dispose();
    _recorder.closeRecorder();
    _audioRecorder.closeRecorder();
    _recordingTimer?.cancel();
    _audioPlayer.closePlayer();
    super.onClose();
  }

  // Request permissions
  Future<bool> _requestPermissions(String type) async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final isAndroid13OrAbove = androidInfo.version.sdkInt >= 33;

    if (type == 'Take Photo') {
      final cameraStatus = await Permission.camera.request();
      return cameraStatus.isGranted;
    } else if (type == 'Take Video') {
      final cameraStatus = await Permission.camera.request();
      final micStatus = await Permission.microphone.request();
      return cameraStatus.isGranted && micStatus.isGranted;
    } else if (type == 'Start Recording') {
      final micStatus = await Permission.microphone.request();
      return micStatus.isGranted;
    } else if (type == 'Gallery') {
      if (isAndroid13OrAbove) {
        final photoStatus = await Permission.photos.request();
        final videoStatus = await Permission.videos.request();
        return photoStatus.isGranted || videoStatus.isGranted;
      } else {
        final storageStatus = await Permission.storage.request();
        return storageStatus.isGranted;
      }
    } else if (type == 'Pick From Files') {
      if (isAndroid13OrAbove) {
        final photoStatus = await Permission.photos.request();
        final videoStatus = await Permission.videos.request();
        final audioStatus = await Permission.audio.request();
        return photoStatus.isGranted ||
            videoStatus.isGranted ||
            audioStatus.isGranted;
      } else {
        final storageStatus = await Permission.storage.request();
        return storageStatus.isGranted;
      }
    }
    return true;
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  void clearRecordings() {
    if (recordingPath.value.isNotEmpty) {
      try {
        final file = File(recordingPath.value);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        print('Error deleting recording file: $e');
      }
      recordingPath.value = '';
    }
    isRecording.value = false;
    recordingDuration.value = Duration.zero;
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  // Capture photo or video
  // Capture photo or video
  Future<void> captureMedia(String type) async {
    // Check if file picker is already active
    if (isFilePickerActive.value) {
      return;
    }

    isFilePickerActive.value = true;

    final isGranted = await _requestPermissions(type);
    if (!isGranted) {
      errorMessage.value =
          'Permission denied for $type. Please enable it in settings.';
      openAppSettings();
      isFilePickerActive.value = false;
      return;
    }

    try {
      final XFile? media = await (type == 'Take Photo'
          ? _picker.pickImage(source: ImageSource.camera)
          : _picker.pickVideo(source: ImageSource.camera));

      if (media != null) {
        // Check file count limit
        if (files.length + links.length >= maxFileCount) {
          errorMessage.value =
              'You can upload a maximum of $maxFileCount files.'.tr;
          isFilePickerActive.value = false;
          return;
        }

        // Check file size
        final fileSize = await media.length();
        if (fileSize > maxFileSize) {
          errorMessage.value =
              'File "${media.name}" exceeds the 500MB size limit.'.tr;
          isFilePickerActive.value = false;
          return;
        }

        // Check file extension against backend requirements
        final extension = media.path.split('.').last.toLowerCase();
        if (!backendAllowedExtensions.contains(extension)) {
          errorMessage.value =
              'File type "$extension" is not supported. Please use: ${backendAllowedExtensions.join(', ')}'
                  .tr;
          isFilePickerActive.value = false;
          return;
        }

        final file = PlatformFile(
          name: media.name,
          path: media.path,
          size: fileSize,
        );
        files.add(file);
      }
    } catch (e) {
      errorMessage.value = 'Error capturing $type: $e';
    } finally {
      isFilePickerActive.value = false;
    }
  }

  // Pick from gallery
  // Pick from gallery
  Future<void> pickFromGallery(int tabIndex) async {
    // Check if file picker is already active
    if (isFilePickerActive.value) {
      return;
    }

    isFilePickerActive.value = true;

    final isGranted = await _requestPermissions('Gallery');
    if (!isGranted) {
      errorMessage.value =
          'Permission denied for gallery access. Please enable it in settings.';
      openAppSettings();
      isFilePickerActive.value = false;
      return;
    }

    try {
      final allowedExtensions = {
            0: ['jpg', 'jpeg', 'png'], // Photo Upload
            1: ['mp4', 'mov', 'avi'], // Video Upload
          }[tabIndex] ??
          ['jpg', 'jpeg', 'png'];

      final XFile? media = await (tabIndex == 0
          ? _picker.pickImage(source: ImageSource.gallery)
          : _picker.pickVideo(source: ImageSource.gallery));

      if (media != null) {
        final extension = media.path.split('.').last.toLowerCase();
        if (!allowedExtensions.contains(extension)) {
          errorMessage.value =
              'Invalid file format. Allowed formats: ${allowedExtensions.join(', ')}';
          isFilePickerActive.value = false;
          return;
        }

        // Check file count limit
        if (files.length + links.length >= maxFileCount) {
          errorMessage.value =
              'You can upload a maximum of $maxFileCount files.'.tr;
          isFilePickerActive.value = false;
          return;
        }

        // Check file size
        final fileSize = await media.length();
        if (fileSize > maxFileSize) {
          errorMessage.value =
              'File "${media.name}" exceeds the 500MB size limit.'.tr;
          isFilePickerActive.value = false;
          return;
        }

        // Check file extension against backend requirements
        if (!backendAllowedExtensions.contains(extension)) {
          errorMessage.value =
              'File type "$extension" is not supported. Please use: ${backendAllowedExtensions.join(', ')}'
                  .tr;
          isFilePickerActive.value = false;
          return;
        }

        final file = PlatformFile(
          name: media.name,
          path: media.path,
          size: fileSize,
        );
        files.add(file);
      }
    } catch (e) {
      errorMessage.value = 'Error picking from gallery: $e';
    } finally {
      isFilePickerActive.value = false;
    }
  }

  // Start audio recording
  Future<void> startRecording() async {
    try {
      // Check permissions
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        errorMessage.value = 'Microphone permission not granted';
        return;
      }

      // Check if recorder is already running
      if (isRecording.value) {
        return;
      }

      // Check file limit - use consistent message
      if (files.length + links.length >= maxFileCount) {
        errorMessage.value =
            'You can upload a maximum of $maxFileCount files.'.tr;
        return;
      }

      // Get storage directory
      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';

      // Determine supported codec
      Codec codec = Codec.aacADTS;
      if (!await _audioRecorder.isEncoderSupported(Codec.aacADTS)) {
        codec = Codec.defaultCodec;
        print('Using default codec: $codec');
      }

      // Start recording
      await _audioRecorder.startRecorder(
        toFile: path,
        codec: codec,
      );

      // Update state
      isRecording.value = true;
      recordingPath.value = path;
      recordingDuration.value = Duration.zero;

      // Start timer to update duration
      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        recordingDuration.value += const Duration(seconds: 1);
      });

      Get.snackbar(
        'Recording',
        'Recording started...',
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      print('Error starting recording: $e');
      errorMessage.value = 'Failed to start recording';
      isRecording.value = false;
    }
  }

  // Stop audio recording
  Future<void> stopRecording() async {
    try {
      if (!isRecording.value) return;

      // Stop recording
      await _audioRecorder.stopRecorder();

      // Cancel timer
      _recordingTimer?.cancel();
      _recordingTimer = null;

      // Add recording to files list
      if (recordingPath.value.isNotEmpty) {
        final file = File(recordingPath.value);
        if (await file.exists()) {
          final platformFile = PlatformFile(
            name: 'recording_${DateTime.now().millisecondsSinceEpoch}.aac',
            path: recordingPath.value,
            size: await file.length(),
          );
          files.add(platformFile);
          files.refresh(); // Force UI update
        }
      }

      Get.snackbar(
        'Recording',
        'Recording saved',
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      print('Error stopping recording: $e');
      errorMessage.value = 'Failed to save recording';
    } finally {
      isRecording.value = false;
      recordingPath.value = '';
      recordingDuration.value = Duration.zero;
    }
  }

  Future<void> playRecording(String path) async {
    try {
      if (await File(path).exists()) {
        await _audioPlayer.startPlayer(
          fromURI: path,
          codec: Codec.aacADTS,
          whenFinished: () {
            // Optional: Update UI when playback completes
          },
        );
      } else {
        errorMessage.value = 'Audio file not found';
      }
    } catch (e) {
      print('Error playing recording: $e');
      errorMessage.value = 'Failed to play recording';
    }
  }

  Future<void> stopPlayback() async {
    try {
      await _audioPlayer.stopPlayer();
    } catch (e) {
      print('Error stopping playback: $e');
    }
  }

  // Add link
  Future<void> addLink(BuildContext context) async {
    final TextEditingController linkController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add a Link'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: linkController,
                decoration: InputDecoration(
                  labelText: 'Website URL'.tr,
                  hintText: 'https://example.com',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel'.tr),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final input = linkController.text.trim();
                      final uri = Uri.tryParse(input);

                      if (uri == null || !uri.hasAbsolutePath) {
                        errorMessage.value = 'Please enter a valid URL.'.tr;
                        return;
                      }

                      if (links.length + files.length >= 5) {
                        errorMessage.value =
                            'You can add a maximum of 5 items (files and links).'
                                .tr;
                        Navigator.pop(context); // closes dialog without result
                        return;
                      }

                      links.add(input);
                      Navigator.pop(context, true);
                    },
                    child: Text('Add Link'.tr),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );

    // Optional: You can handle `result` here
    if (result == true) {
      // Link was added
    }
  }

  // Pick files
  // Pick files
  Future<void> pickFiles(int tabIndex) async {
    // Check if file picker is already active
    if (isFilePickerActive.value) {
      return;
    }

    isFilePickerActive.value = true;

    final isGranted = await _requestPermissions('Pick From Files'.tr);
    if (!isGranted) {
      errorMessage.value =
          'Permission denied for file access. Please enable it in settings.'.tr;
      openAppSettings();
      isFilePickerActive.value = false;
      return;
    }

    final allowedExtensions = {
          0: ['jpg', 'jpeg', 'png'],
          1: ['mp4', 'mov', 'avi'],
          2: ['mp3', 'wav', 'm4a'],
          3: [
            'jpg',
            'jpeg',
            'png',
            'mp4',
            'mov',
            'avi',
            'mp3',
            'wav',
            'txt',
            'pdf',
            'doc',
            'docx'
          ],
        }[tabIndex] ??
        [
          'jpg',
          'jpeg',
          'png',
          'mp4',
          'mov',
          'avi',
          'mp3',
          'wav',
          'txt',
          'pdf',
          'doc',
          'docx'
        ];

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result != null) {
        final newFiles = result.files;

        // Check file count limit
        if (files.length + newFiles.length + links.length > maxFileCount) {
          errorMessage.value =
              'You can upload a maximum of $maxFileCount files.'.tr;
          isFilePickerActive.value = false;
          return;
        }

        // Validate each file
        for (var file in newFiles) {
          // Check file size
          if (file.size > maxFileSize) {
            errorMessage.value =
                'File "${file.name}" exceeds the 500MB size limit.'.tr;
            isFilePickerActive.value = false;
            return;
          }

          // Check file extension against backend requirements
          final extension = file.extension?.toLowerCase() ?? '';
          if (!backendAllowedExtensions.contains(extension)) {
            errorMessage.value =
                'File type "$extension" is not supported. Please use: ${backendAllowedExtensions.join(', ')}'
                    .tr;
            isFilePickerActive.value = false;
            return;
          }
        }

        files.addAll(newFiles);
      }
    } catch (e) {
      errorMessage.value = 'Error picking files: $e';
    } finally {
      // Always reset the flag when done
      isFilePickerActive.value = false;
    }
  }

  // Verify ticket
  // In user_create_controller.dart, modify the verifyTicket method

  Future<void> verifyTicket() async {
    if (ticketNumber.value.isEmpty) {
      errorMessage.value = 'Please enter a ticket number.'.tr;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please log in to verify ticket.'.tr;
        Get.offAllNamed('/login');
        return;
      }

      final client = GraphQLClient(
        link: HttpLink(
          '${Config.baseUrl}/graphql',
          defaultHeaders: {'Authorization': 'Bearer $token'},
        ),
        cache: GraphQLCache(),
      );

      const query = r'''
      query VerifyTicket($ticketNumber: String!) {
        verifyTicket(ticketNumber: $ticketNumber) {
          ticketNumber
          companyName
          roomName
          staffName
          staffId
          servedDate
          ticketCreatedAt
          calledAt
          served
        }
      }
    ''';

      final result = await client.query(
        QueryOptions(
          document: gql(query),
          variables: {'ticketNumber': ticketNumber.value},
          fetchPolicy: FetchPolicy.networkOnly,
          errorPolicy: ErrorPolicy.all,
        ),
      );

      if (result.hasException) {
        errorMessage.value =
            'Failed to verify ticket: ${result.exception.toString()}'.tr;
        return;
      }

      final data = result.data?['verifyTicket'] as Map<String, dynamic>?;
      if (data != null) {
        ticketInfo.value = data;
        isTicketVerified.value = true;
        Get.snackbar(
          'Success'.tr,
          'Ticket verified successfully!'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 2),
        );
      } else {
        errorMessage.value = 'Ticket not found.'.tr;
        isTicketVerified.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Error verifying ticket: $e'.tr;
      isTicketVerified.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  // Retry ticket verification
  void retryTicket() {
    ticketNumber('');
    ticketInfo.clear();
    isTicketVerified(false);
    errorMessage('');
  }

  // Navigate to previous step
  void previousStep() {
    // Clear any previous error messages when changing steps
    errorMessage.value = '';
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  // Set incident time
  void setIncidentTime(DateTime time) {
    incidentTime.value = time;
  }

  // Set incident place
  void setIncidentPlace(String place) {
    incidentPlace.value = place;
  }

  // Submit complaint
  Future<void> submitComplaint() async {
    final qrController = Get.find<QrscannerController>();
    final isQrScanned =
        qrController.scannedCode.isNotEmpty && staffInfo.isNotEmpty;

    // Validate inputs
    if (!isQrScanned) {
      if (selectedBranchId.value.isEmpty) {
        errorMessage.value = 'Please select a branch.'.tr;
        return;
      }
      if (selectedServiceId.value.isEmpty) {
        errorMessage.value = 'Please select a service.'.tr;
        return;
      }
    }
    if (detail.value.isEmpty) {
      errorMessage.value = 'Please provide report details.'.tr;
      return;
    }
    // Validate that files are provided if hasDocument is true
    if (hasDocument.value && files.isEmpty) {
      errorMessage.value =
          'Please upload at least one file when attachments are selected.'.tr;
      return;
    }

    // Validate file extensions and sizes
    for (var file in files) {
      final extension = file.extension?.toLowerCase() ?? '';
      if (!backendAllowedExtensions.contains(extension)) {
        errorMessage.value =
            'File type "$extension" is not supported. Please remove it and try again.'
                .tr;
        return;
      }
      if (file.size > maxFileSize) {
        errorMessage.value =
            'File "${file.name}" exceeds the 500MB size limit. Please remove it and try again.'
                .tr;
        return;
      }
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please log in to submit complaint.'.tr;
        Get.offAllNamed('/login');
        return;
      }

      final selectedBranch = branches.firstWhere(
        (branch) => branch['id'].toString() == selectedBranchId.value,
        orElse: () => {'name': 'Unknown Branch'},
      );
      final branchName = isQrScanned
          ? (staffInfo['branch']?['name']?.toString() ?? 'Unknown Branch')
          : (selectedBranch['name']?.toString() ?? 'Unknown Branch');

      final now = DateTime.now().toUtc();
      final serviceDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      // Replace the query in your submitComplaint method with this:
      const query = r'''
  mutation CreateCorruptionReport($input: CorruptionReportCreateInput!) {
    createCorruptionReport(input: $input) {
      id
      description
      category
      rating
      feedback_description
      service {
        id
        name
      }
      branch {
        id
        name
      }
      status
      created_at
    }
  }
''';

      final input = {
        'description': detail.value.trim(),
        'category': 'complaint',
        'service_id': isQrScanned &&
                staffInfo['service'] != null &&
                staffInfo['service']['id'] != null
            ? staffInfo['service']['id'].toString()
            : selectedServiceId.value,
        'branch_id': isQrScanned &&
                staffInfo['branch'] != null &&
                staffInfo['branch']['id'] != null
            ? staffInfo['branch']['id'].toString()
            : selectedBranchId.value,
        'staff_id': ticketNumber.value.isNotEmpty ? ticketNumber.value : null,
        'institution_name': isQrScanned &&
                staffInfo['branch'] != null &&
                staffInfo['branch']['name'] != null
            ? staffInfo['branch']['name'].toString()
            : 'Unknown Institution', // Provide default value
        'responsible_person': isQrScanned && staffInfo['name'] != null
            ? staffInfo['name'].toString()
            : 'Unknown Person', // Provide default value instead of null
        'responsible_person_phone':
            isQrScanned && staffInfo['phone_number'] != null
                ? staffInfo['phone_number'].toString()
                : 'Unknown Phone', // Provide default value
        'responsible_person_address': isQrScanned &&
                staffInfo['branch'] != null &&
                staffInfo['branch']['description'] != null
            ? staffInfo['branch']['description'].toString()
            : 'Unknown Address', // Provide default value
        'report_place': branchName,
        'associated_parties': null,
        'region_id': null,
        'service_date': serviceDate,
        'share_contact': contactMe.value,
        'is_complaint': true,
        'first_name':
            firstName.value.isNotEmpty ? firstName.value : 'Anonymous',
        'father_name': lastName.value.isNotEmpty ? lastName.value : null,
        'grand_father_name': surname.value.isNotEmpty ? surname.value : null,
        'files': files.isNotEmpty
            ? List.generate(files.length, (index) => null)
            : [],
      };

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Config.baseUrl}/graphql'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      // request.headers['Content-Type'] = 'multipart/form-data';

      final operations = {
        'query': query,
        'variables': {'input': input},
      };

      // Construct the map field as an array of arrays with a single string path
      final map = <String, List<String>>{};
      for (var i = 0; i < files.length; i++) {
        map['file$i'] = ['variables.input.attachments.$i'];
      }

      request.fields['operations'] = jsonEncode(operations);
      request.fields['map'] = jsonEncode(map);

      for (var i = 0; i < files.length; i++) {
        final file = files[i];
        if (file.path == null) {
          errorMessage.value = 'File path for "${file.name}" is missing.'.tr;
          isLoading.value = false;
          return;
        }
        final fileData = await File(file.path!).readAsBytes();
        final mimeType =
            lookupMimeType(file.path!) ?? 'application/octet-stream';
        request.files.add(
          http.MultipartFile.fromBytes(
            'file$i',
            fileData,
            filename: file.name,
            contentType: http_parser.MediaType.parse(mimeType),
          ),
        );
      }

      print('Submitting complaint with input: $input');
      print('File map: $map');
      print('Request URL: ${Config.baseUrl}/graphql');
      print('Request headers: ${request.headers}');
      print('Multipart fields: ${request.fields}');
      print('Multipart files: ${request.files.map((f) => f.field).toList()}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Raw server response: $responseBody');

      if (responseBody.trim().startsWith('<html')) {
        String errorMsg;

        if (response.statusCode == 413) {
          errorMsg =
              'The attached file is too large. Please upload a smaller file.'
                  .tr;
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          errorMsg =
              'Authentication error: Invalid or expired token. Please log in again.'
                  .tr;
          await prefs.remove('access_token');
          Get.offAllNamed('/login');
        } else if (response.statusCode == 404) {
          errorMsg =
              'Service not found. Please verify the system configuration.'.tr;
        } else if (response.statusCode >= 500) {
          errorMsg =
              'Server error: Please try again later or contact support.'.tr;
        } else {
          errorMsg = 'Unexpected server response. Please try again later.'.tr;
        }

        print(
            'Submission error: $errorMsg (Status code: ${response.statusCode})');

        Get.snackbar(
          'Error'.tr,
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 4),
          isDismissible: true,
        );
        return;
      }

      final result = jsonDecode(responseBody);

      if (response.statusCode != 200 || result.containsKey('errors')) {
        String errorMsg =
            'Failed to submit complaint: ${result['errors']?.toString() ?? response.reasonPhrase}'
                .tr;
        if (result['errors'] != null && result['errors'].isNotEmpty) {
          errorMsg = result['errors'][0]['message'];
          if (errorMsg.toLowerCase().contains('unauthorized') ||
              errorMsg.toLowerCase().contains('token')) {
            await prefs.remove('access_token');
            Get.offAllNamed('/login');
            errorMsg = 'Session expired. Please log in again.'.tr;
          } else if (errorMsg.toLowerCase().contains('service_id') ||
              errorMsg.toLowerCase().contains('branch_id')) {
            errorMsg =
                'Invalid branch or service selected. Please try again.'.tr;
          } else if (errorMsg.toLowerCase().contains('service_date')) {
            errorMsg = 'Invalid date format. Please try again.'.tr;
          }
        } else if (response.statusCode != 200) {
          errorMsg =
              'Network error: ${response.reasonPhrase} (Status code: ${response.statusCode})'
                  .tr;
        }
        print('Submission error: $errorMsg');
        Get.snackbar(
          'Error'.tr,
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 4),
          isDismissible: true,
        );
        return;
      }

      final data =
          result['data']?['createCorruptionReport'] as Map<String, dynamic>?;
      if (data == null) {
        print('Submission error: No data returned from server');
        Get.snackbar(
          'Error'.tr,
          'No data returned from server.'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 4),
          isDismissible: true,
        );
        return;
      }

      // Check if attachments were included in the response
      if (files.isNotEmpty &&
          (data['attachments'] == null ||
              (data['attachments'] as List).isEmpty)) {
        print(
            'Warning: Files were uploaded but no attachments returned in response');
        Get.snackbar(
          'Warning'.tr,
          'Complaint submitted, but attachments may not have been saved. Please verify with support.'
              .tr,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 4),
          isDismissible: true,
        );
      }

      print('Complaint submitted successfully: $data');
      Get.dialog(
        _buildSuccessPopup(data['id'],
            ticketNumber.value.isNotEmpty ? ticketNumber.value : 'N/A'),
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.3),
        transitionDuration: Duration(milliseconds: 300),
        transitionCurve: Curves.easeInOut,
      );

      resetForm();
      qrController.clearScannedCode(); // Clear QR code after submission
    } catch (e) {
      print('Unexpected error during submission: $e');
      String errorMsg = 'Failed to submit complaint: $e'.tr;
      if (e is FormatException &&
          e.toString().contains('Unexpected character')) {
        errorMsg =
            'Server returned invalid response format (possibly HTML). Please check the server configuration or URL.'
                .tr;
      }
      Get.snackbar(
        'Error'.tr,
        errorMsg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 4),
        isDismissible: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Widget _buildSuccessPopup(String reportId, String ticketNumber) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      backgroundColor: Colors.white,
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 80,
                    semanticLabel: 'Success',
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            Text(
              'Report Submitted Successfully!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Please save this information for future reference:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            _buildInfoRow('Track Number:', reportId),
            SizedBox(height: 12),
            // _buildInfoRow('Ticket Number:', ticketNumber),
            // SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please take a screenshot of this information for your records.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    FlutterClipboard.copy(
                        'Track Number: $reportId\nTicket Number: $ticketNumber');
                    Get.snackbar('Copied', 'Report details copied to clipboard',
                        snackPosition: SnackPosition.TOP);
                  },
                  icon: Icon(Icons.copy, size: 18),
                  label: Text('Copy Details'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue.shade600,
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.offAllNamed('/bottom-nav-home', arguments: {
                      'success_message': 'Report is successfully added.'
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  // Updated to return nullable String
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }
}

class UploadTab {
  final IconData icon;
  final String uploadTitle;
  final List<UploadAction> actions;

  UploadTab({
    required this.icon,
    required this.uploadTitle,
    required this.actions,
  });
}

class UploadAction {
  final IconData icon;
  final String label;

  UploadAction(this.icon, this.label);
}
