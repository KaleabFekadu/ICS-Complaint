import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/painting.dart' as painting;
import 'dart:ui' as ui;

class PdfService {
  Future<Uint8List> generateRequestPdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    final logo = pw.MemoryImage(
      (await DefaultAssetBundle.of(Get.context!).load('assets/logos/ccilogo.jpg'))
          .buffer
          .asUint8List(),
    );

    // Load fonts
    final abyssinicaFont = pw.Font.ttf(
      await DefaultAssetBundle.of(Get.context!)
          .load('assets/fonts/AbyssinicaSIL-Regular.ttf'),
    );
    final timesRomanFont = pw.Font.ttf(
      await DefaultAssetBundle.of(Get.context!)
          .load('assets/fonts/Times-Roman.ttf'),
    );

    // Generate QR code
    final qrCodeImage = await _generateQrCode(data['request_id']);
    final qrCode = pw.MemoryImage(qrCodeImage);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // Header
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'የኢትዮጵያ ፌዴራላዊ ዲሞክራሲያዊ\nሪፐብሊክ\nየሕገ መንግስት ጉዳዮች\nአጣሪ ጉባኤ ጽ/ቤት',
                        style: pw.TextStyle(
                          font: abyssinicaFont,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#4169a5'),
                          lineSpacing: 1,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Image(logo, width: 90),
                      pw.Text(
                        'The Federal Democratic Republic\nof Ethiopia\nSecretariat of\nCouncil of Constitutional Inquiry',
                        style: pw.TextStyle(
                          font: timesRomanFont,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#4169a5'),
                          lineSpacing: 1,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(color: PdfColor.fromHex('#4169a5'), thickness: 1),
                  pw.SizedBox(height: 10),

                  // Header Text
                  pw.Text(
                    'Case Flow Management System - Generated on ${DateTime.now().toString().substring(0, 10)}',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColor.fromHex('#666666'),
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 15),

                  // Title
                  pw.Text(
                    'Request Details',
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColor.fromHex('#1a365d'),
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 15),
                  pw.Divider(color: PdfColor.fromHex('#e2e8f0'), thickness: 1),

                  // Content
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildSection(
                              title: 'Basic Information',
                              font: abyssinicaFont,
                              items: [
                                {'label': 'Request ID:', 'value': data['request_id']},
                                {
                                  'label': 'QR Code:',
                                  'value': pw.Container(
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border.all(
                                        color: PdfColor.fromHex('#e2e8f0'),
                                      ),
                                      borderRadius: pw.BorderRadius.circular(3),
                                    ),
                                    padding: pw.EdgeInsets.all(5),
                                    child: pw.Image(qrCode, width: 50, height: 50),
                                  ),
                                },
                                {'label': 'Status:', 'value': data['status']},
                                {'label': 'Request Date:', 'value': data['requestDate']},
                              ],
                            ),
                            _buildSection(
                              title: 'Request Details',
                              font: abyssinicaFont,
                              items: [
                                {'label': 'Case Type:', 'value': data['caseType']},
                                {
                                  'label': 'Affair Desc:',
                                  'value':
                                  '${data['affairDescription'].substring(0, data['affairDescription'].length > 35 ? 35 : data['affairDescription'].length)}${data['affairDescription'].length > 35 ? '...' : ''}',
                                },
                                {
                                  'label': 'Complaint:',
                                  'value':
                                  '${data['constitutionalComplaint'].substring(0, data['constitutionalComplaint'].length > 35 ? 35 : data['constitutionalComplaint'].length)}${data['constitutionalComplaint'].length > 35 ? '...' : ''}',
                                },
                              ],
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 15),
                      // Right Column
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildSection(
                              title: 'Applicant Information',
                              font: abyssinicaFont,
                              items: [
                                {'label': 'Name:', 'value': data['applicantName']},
                                {'label': 'Region:', 'value': data['region']},
                                {'label': 'Zone:', 'value': data['zone']},
                                {'label': 'City:', 'value': data['city']},
                                {'label': 'Sub-city:', 'value': data['subCity']},
                                {'label': 'Woreda:', 'value': data['woreda']},
                                {'label': 'Phone:', 'value': data['phoneNumber']},
                                if (data['representative'] != 'N/A')
                                  {
                                    'label': 'Representative:',
                                    'value': data['representative'],
                                  },
                              ],
                            ),
                            _buildSection(
                              title: 'Respondent Information',
                              font: abyssinicaFont,
                              items: [
                                {'label': 'Name:', 'value': data['respondentName']},
                                {'label': 'Region:', 'value': data['respondentRegion']},
                                {'label': 'Zone:', 'value': data['respondentZone']},
                                {'label': 'City:', 'value': data['respondentCity']},
                                {
                                  'label': 'Sub-city:',
                                  'value': data['respondentSubCity'],
                                },
                                {
                                  'label': 'Woreda:',
                                  'value': data['respondentWoreda'],
                                },
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 15),
                  pw.Divider(color: PdfColor.fromHex('#e2e8f0'), thickness: 1),

                  // Footer
                  pw.Text(
                    'FDRE - Council of Constitutional Inquiry\nContact: constitutionalinquiry.et@gmail.com | Case Flow Management System',
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: PdfColor.fromHex('#666666'),
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
              // Custom Footer
              pw.Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: pw.Column(
                  children: [
                    pw.Divider(color: PdfColor.fromHex('#fcce03'), thickness: 2),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            'ስልክ/Tel: +251 11-1-116888\n: +251 11-1-562289\n: +251 11-1-266724\nነፃ የስልክ መስመር: 6939',
                            style: pw.TextStyle(
                              font: abyssinicaFont,
                              fontSize: 6,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#4169a5'),
                            ),
                            textAlign: pw.TextAlign.left,
                          ),
                        ),
                        pw.Container(
                          width: 2,
                          height: 40,
                          color: PdfColor.fromHex('#fcce03'),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            'ፋክስ/Fax: +251 11-1-116888\nፓ.ሳ.ቁ/P.O.Box: 22627\nአዲስ አበባ\nAddis Ababa',
                            style: pw.TextStyle(
                              font: abyssinicaFont,
                              fontSize: 6,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#4169a5'),
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          width: 2,
                          height: 40,
                          color: PdfColor.fromHex('#fcce03'),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            'ኢ-ሜይል/E-mail: constitutionalinquiry.et@gmail.com\nድረ-ገፅ/Website: www.cci.gov.et\nፌስቡክ-ገፅ: http://www.facebook.com/CCIFDRE/\nቴሌግራም/Telegram: https://t.me/CCI-sec',
                            style: pw.TextStyle(
                              font: abyssinicaFont,
                              fontSize: 6,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#4169a5'),
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildSection({
    required String title,
    required pw.Font font,
    required List<Map<String, dynamic>> items,
  }) {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      margin: pw.EdgeInsets.only(bottom: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#e2e8f0')),
        borderRadius: pw.BorderRadius.circular(3),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 11,
              color: PdfColor.fromHex('#2c5282'),
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          ...items.map((item) {
            return pw.Padding(
              padding: pw.EdgeInsets.only(bottom: 5),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    item['label'],
                    style: pw.TextStyle(
                      font: font,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#2d3748'),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  item['value'] is pw.Widget
                      ? item['value']
                      : pw.Expanded(
                    child: pw.Text(
                      item['value'].toString(),
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Future<Uint8List> _generateQrCode(String text) async {
    final qrValidationResult = QrValidator.validate(
      data: text,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
    );

    if (qrValidationResult.status == QrValidationStatus.valid) {
      final qrCode = qrValidationResult.qrCode!;
      final painter = QrPainter.withQr(
        qr: qrCode,
        emptyColor: const Color(0xFFFFFFFF), // Use Flutter Color
        dataModuleStyle: const QrDataModuleStyle(
          color: Color(0xFF000000), // Use Flutter Color
        ),
      );

      final image = await painter.toImage(200);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    }
    return Uint8List(0);
  }

  Future<String> savePdf(Uint8List pdfData, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(pdfData); // Fixed: Changed 'write' to 'writeAsBytes'
    return file.path;
  }
}