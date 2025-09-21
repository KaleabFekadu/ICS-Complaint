
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



class CreateComplaintController extends GetxController {
  // Form data
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
  final _formKey = GlobalKey<FormState>();

  // Add these constants at the top of the UserCreateController class
  static const int maxFileSize = 500 * 1024 * 1024; // 500MB in bytes
  static const int maxFileCount = 5;
  static const List<String> allowedExtensions = [
    'jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi', 'mp3', 'wav', 'txt', 'pdf', 'doc', 'docx'
  ];
  static const List<String> backendAllowedExtensions = [
    'jpg', 'jpeg', 'png', 'mp4', 'mp3', 'wav', 'pdf', 'doc', 'docx'
  ]; // Backend doesn't support mov, avi, txt


  // Ticket information
  var ticketInfo = <String, dynamic>{}.obs;
  var isTicketVerified = false.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  var isFilePickerActive = false.obs;

  // Add to class properties
  var selectedBranch = ''.obs;
  var selectedService = ''.obs;
  final branches = ['Branch A', 'Branch B', 'Branch C'].obs;
  final servicesByBranch = {
    'Branch A': ['Service A1', 'Service A2', 'Service A3'],
    'Branch B': ['Service B1', 'Service B2'],
    'Branch C': ['Service C1', 'Service C2', 'Service C3', 'Service C4'],
  }.obs;

  // Add method to get services for selected branch
  List<String> getServicesForBranch(String branch) {
    return servicesByBranch[branch] ?? [];
  }

  // Audio recording variables
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();


  // Change the recorder initialization
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  var isRecording = false.obs;
  var recordingPath = ''.obs;
  var recordingDuration = Duration.zero.obs;
  Timer? _recordingTimer;


  // Arguments from ChildCategoriesView
  String? childCategoryId;
  String? categoryId;
  var categoryName = ''.obs;

  // SendReportNewController fields
  var selectedTab = 0.obs;
  RxBool contactMe = false.obs;
  Rx<DateTime?> incidentTime = Rx<DateTime?>(null);
  RxString incidentPlace = ''.obs;
  final descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  String get formattedTime {
    if (incidentTime.value == null) return 'Select Time';
    return DateFormat('MMM d, yyyy - HH:mm').format(incidentTime.value!);
  }

  // Tabs for upload options
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
    resetForm();

    final args = Get.arguments as Map<String, dynamic>?;
    childCategoryId = args?['child_category'] as String?;
    categoryId = args?['category'] as String?;
    categoryName.value =
        args?['category_name'] as String? ?? 'Unknown Category';

    // Sync controllers with observables
    ticketNumberController.text = ticketNumber.value;
    firstNameController.text = firstName.value;
    lastNameController.text = lastName.value;
    surnameController.text = surname.value;
    descriptionController.text = detail.value;

    // Add listeners
    ticketNumberController
        .addListener(() => ticketNumber.value = ticketNumberController.text);
    firstNameController
        .addListener(() => firstName.value = firstNameController.text);
    lastNameController
        .addListener(() => lastName.value = lastNameController.text);
    surnameController.addListener(() => surname.value = surnameController.text);
    descriptionController
        .addListener(() => detail.value = descriptionController.text);

    // Initialize audio recorder
    await _initAudioRecorder();
    await _initAudioPlayer(); // Initialize player
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
    selectedBranch.value = '';
    selectedService.value = '';
    clearRecordings();
    // Reset text controllers
    ticketNumberController.clear();
    firstNameController.clear();
    lastNameController.clear();
    surnameController.clear();
    descriptionController.clear();
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
          errorMessage.value = 'You can upload a maximum of $maxFileCount files.'.tr;
          isFilePickerActive.value = false;
          return;
        }

        // Check file size
        final fileSize = await media.length();
        if (fileSize > maxFileSize) {
          errorMessage.value = 'File "${media.name}" exceeds the 500MB size limit.'.tr;
          isFilePickerActive.value = false;
          return;
        }

        // Check file extension against backend requirements
        final extension = media.path.split('.').last.toLowerCase();
        if (!backendAllowedExtensions.contains(extension)) {
          errorMessage.value = 'File type "$extension" is not supported. Please use: ${backendAllowedExtensions.join(', ')}'.tr;
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
          errorMessage.value = 'You can upload a maximum of $maxFileCount files.'.tr;
          isFilePickerActive.value = false;
          return;
        }

        // Check file size
        final fileSize = await media.length();
        if (fileSize > maxFileSize) {
          errorMessage.value = 'File "${media.name}" exceeds the 500MB size limit.'.tr;
          isFilePickerActive.value = false;
          return;
        }

        // Check file extension against backend requirements
        if (!backendAllowedExtensions.contains(extension)) {
          errorMessage.value = 'File type "$extension" is not supported. Please use: ${backendAllowedExtensions.join(', ')}'.tr;
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
        errorMessage.value = 'You can upload a maximum of $maxFileCount files.'.tr;
        return;
      }

      // Get storage directory
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';

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
                            'You can add a maximum of 5 items (files and links).'.tr;
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
      3: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi', 'mp3', 'wav', 'txt', 'pdf', 'doc', 'docx'],
    }[tabIndex] ??
        ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi', 'mp3', 'wav', 'txt', 'pdf', 'doc', 'docx'];

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
          errorMessage.value = 'You can upload a maximum of $maxFileCount files.'.tr;
          isFilePickerActive.value = false;
          return;
        }

        // Validate each file
        for (var file in newFiles) {
          // Check file size
          if (file.size > maxFileSize) {
            errorMessage.value = 'File "${file.name}" exceeds the 500MB size limit.'.tr;
            isFilePickerActive.value = false;
            return;
          }

          // Check file extension against backend requirements
          final extension = file.extension?.toLowerCase() ?? '';
          if (!backendAllowedExtensions.contains(extension)) {
            errorMessage.value = 'File type "$extension" is not supported. Please use: ${backendAllowedExtensions.join(', ')}'.tr;
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
    if (selectedBranch.isEmpty || selectedService.isEmpty) {
      errorMessage.value = 'Please select both branch and service.'.tr;
      isTicketVerified(false);
      return;
    }

    isLoading(true);
    errorMessage('');

    try {
      // Simulate ticket verification with branch and service
      // This is a placeholder - replace with actual API call when integrating
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      ticketInfo.assignAll({
        'ticketNumber': 'TICKET-${selectedBranch.value.split(' ').last}-${selectedService.value.split(' ').last}',
        'companyName': selectedBranch.value,
        'roomName': 'Room 101',
        'staffName': 'Staff Member',
        'ticketCreatedAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        'calledAt': null,
        'servedDate': null,
        'served': false,
      });
      isTicketVerified(true);

      final today = DateTime.now().toIso8601String().split('T')[0];
      final ticketCreatedAtDate = ticketInfo['ticketCreatedAt']?.split(' ')[0];
      if (!(ticketInfo['served'] ?? false) && ticketCreatedAtDate == today) {
        errorMessage.value =
        'Thank you for your patience. Our team is currently processing your request, and we will be contacting you shortly.';
      }
    } catch (e, stackTrace) {
      print('Ticket verification error: $e\nStack trace: $stackTrace');
      errorMessage.value = 'Ticket verification service is unavailable';
      isTicketVerified(false);
    } finally {
      isLoading(false);
    }
  }

  // Retry ticket verification
  void retryTicket() {
    ticketNumber('');
    ticketInfo.clear();
    isTicketVerified(false);
    errorMessage('');
    selectedBranch.value = '';
    selectedService.value = '';
  }

  // Navigate to next step
  void nextStep() {
    // Clear any previous error messages when changing steps
    errorMessage.value = '';

    if (currentStep.value == 0 && !isTicketVerified.value) {
      errorMessage.value = 'Please verify the ticket number.';
      return;
    }
    if (currentStep.value == 2 && detail.isEmpty) {
      errorMessage.value = 'Please provide report details.';
      return;
    }
    if (currentStep.value < 3) {
      currentStep.value++;
    }
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
    if (detail.isEmpty) {
      errorMessage.value = 'Please provide report details.';
      return;
    }

    for (var file in files) {
      final extension = file.extension?.toLowerCase() ?? '';
      if (!backendAllowedExtensions.contains(extension)) {
        errorMessage.value = 'File type "$extension" is not supported. Please remove it and try again.'.tr;
        return;
      }

      if (file.size > maxFileSize) {
        errorMessage.value = 'File "${file.name}" exceeds the 500MB size limit. Please remove it and try again.'.tr;
        return;
      }
    }

    isLoading(true);
    errorMessage('');

    if (childCategoryId == null || categoryId == null) {
      errorMessage.value = 'Invalid category selection. Please try again.';
      isLoading(false);
      return;
    }

    final query = '''
  mutation CreateCorruptionReport(\$input: CorruptionReportCreateInput!) {
    createCorruptionReport(input: \$input) {
      id
      report_place
      responsible_person
      description
    }
  }
  ''';

    // Prepare input data
    final input = {
      'description': detail.value,
      'institution_name': ticketInfo['companyName'],
      'responsible_person': ticketInfo['staffName'],
      'responsible_person_address': ticketInfo['companyName'],
      'report_category_id': int.parse(categoryId!),
      'report_category': int.parse(childCategoryId!),
      'report_place': incidentPlace.value.isNotEmpty
          ? incidentPlace.value
          : ticketInfo['companyName'],
      'incident_time': incidentTime.value != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(incidentTime.value!)
          : ticketInfo['servedDate'],
      'share_contact': contactMe.value,
      'is_complaint': true,
      'ticket_number': ticketInfo['ticketNumber'],
      'company_name': ticketInfo['companyName'],
      'room_name': ticketInfo['roomName'],
      'staff_name': ticketInfo['staffName'],
      'ticket_created_at': ticketInfo['ticketCreatedAt'],
      'called_at': ticketInfo['calledAt'],
      'served_date': ticketInfo['servedDate'],
      'served': ticketInfo['served'] ?? false,
      if (firstName.value.isNotEmpty) 'first_name': firstName.value,
      if (lastName.value.isNotEmpty) 'father_name': lastName.value,
      if (surname.value.isNotEmpty) 'grand_father_name': surname.value,
    };

    // Remove null values from the input
    input.removeWhere((key, value) => value == null);

    try {
      final token = await _getToken();

      if (files.isNotEmpty) {
        // Handle case with files (multipart request)
        final request = http.MultipartRequest(
            'POST',
            Uri.parse('${Config.baseUrl}/graphql')
        );

        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }

        // Add attachments to input if files exist
        input['attachments'] = files.map((file) => file.name).toList();

        request.fields['operations'] = jsonEncode({
          'query': query,
          'variables': {'input': input},
        });

        final map = files.asMap().map((index, _) =>
            MapEntry('file$index', ['variables.input.attachments.$index']));
        request.fields['map'] = jsonEncode(map);

        for (var i = 0; i < files.length; i++) {
          final file = files[i];
          final mimeType =
              lookupMimeType(file.path ?? '') ?? 'application/octet-stream';
          request.files.add(await http.MultipartFile.fromPath(
            'file$i',
            file.path!,
            filename: file.name,
            contentType: http_parser.MediaType.parse(mimeType),
          ));
        }

        final response = await request.send().timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw TimeoutException('Mutation request timed out'),
        );
        await _handleResponse(response);
      } else {
        // Handle case without files (regular JSON request)
        final response = await http.post(
          Uri.parse('${Config.baseUrl}/graphql'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'query': query,
            'variables': {'input': input},
          }),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw TimeoutException('Mutation request timed out'),
        );
        await _handleResponse(response);
      }
    } catch (e, stackTrace) {
      print('Exception during submission: $e\nStack trace: $stackTrace');
      errorMessage.value = 'An error occurred';
    } finally {
      isLoading(false);
    }
  }


  Future<void> _handleResponse(dynamic response) async {
    http.Response responseBody;

    if (response is http.StreamedResponse) {
      responseBody = await http.Response.fromStream(response);
    } else if (response is http.Response) {
      responseBody = response;
    } else {
      throw Exception('Unknown response type');
    }

    print('Raw response body: ${responseBody.body}');

    if (responseBody.statusCode == 200) {
      final responseData = jsonDecode(responseBody.body);
      print('Mutation response: $responseData');

      if (responseData['errors'] != null && responseData['errors'].isNotEmpty) {
        final error = responseData['errors'][0];

        // Prefer debugMessage if available
        final debugMessage = error['extensions']?['debugMessage'];
        final message = debugMessage ?? error['message'] ?? 'An error occurred while submitting the complaint.';

        errorMessage.value = message;
        return;
      }

      // Extract report ID and ticket number
      final reportId = responseData['data']['createCorruptionReport']['id'];
      final ticketNum = ticketInfo['ticketNumber'] ?? 'N/A';

      // Show success popup with report details
      Get.dialog(
        _buildSuccessPopup(reportId, ticketNum),
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.3),
        transitionDuration: Duration(milliseconds: 300),
        transitionCurve: Curves.easeInOut,
      );

      // Reset form after successful submission
      resetForm();
    } else {
      errorMessage.value =
      'Failed to submit complaint. Status code: ${responseBody.statusCode}';
      print(
          'HTTP error: Status ${responseBody.statusCode}, Body: ${responseBody.body}');
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
            _buildInfoRow('Ticket Number:', ticketNumber),
            SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
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
                    Get.offAllNamed('/bottom-nav-home',
                        arguments: {
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