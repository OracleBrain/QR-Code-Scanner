import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({super.key});

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String result = '';
  String buttonText = 'Open';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR Code Scanner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text('Result: $result'),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  _launchContent(result);
                },
                child: Text(buttonText),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData.code!;
        print(scanData.code);
        _updateButtonText(result);
      });
    });
  }

  void _updateButtonText(String content) {
    if (content.startsWith('http')) {
      setState(() {
        buttonText = 'Open Link';
      });
    } else if (content.startsWith('tel:')) {
      setState(() {
        buttonText = 'Open Dialer';
      });
    }else if (content.startsWith('MATMSG:') || content.startsWith('MAILTO:')) {
      setState(() {
        buttonText = 'Open Email';
      });
    }else {
      setState(() {
        buttonText = 'Open';
      });
    }
  }

  void _launchContent(String content) async {
    if (content.startsWith('http')) {
      await launchUrl(
        Uri.parse(content),
        mode: LaunchMode.externalApplication,
      );
    } else if (content.startsWith('tel:')) {
      await launchUrl(
        Uri.parse(content),
        mode: LaunchMode.externalApplication,
      );
    } else if (content.startsWith('MATMSG:') || content.startsWith('MAILTO:'))
    {
      final String emailContent = content.replaceFirst(RegExp('MATMSG:TO:|MAILTO:TO:'), '');
      final Uri launchUri = Uri(
          scheme: 'mailto',
          path: emailContent,
          queryParameters: {'subject': ''}
      );
      await launchUrl(launchUri);
    } else {
      print('Unknown content type: $content');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
