import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);


void main() {
  logger.d("Debug log");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyWebViewPage(),
    );
  }
}


class MyWebViewPage extends StatefulWidget {
  const MyWebViewPage({super.key});

  @override
  State<MyWebViewPage> createState() => _MyWebViewPageState();
}

class _MyWebViewPageState extends State<MyWebViewPage> {
  late InAppWebViewController _webViewController;
  late InAppWebView _webView;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter URL...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.greenAccent),
                ),
                style: TextStyle(color: Colors.blueGrey),
                onSubmitted: (value) {
                  // Khi người dùng nhấn Enter, tải lại trang với URL mới
                  if (Uri.tryParse(value)?.hasAbsolutePath == true) {
                    logger.d("Load URL $value");
                    _webViewController.loadUrl(urlRequest: URLRequest(url: WebUri(value)));
                  } else {
                    logger.d("URL $value invalid" );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri("https://truyenfull.io")),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: false,
          clearCache: true,
          userAgent: "CustomUserAgent",
          useHybridComposition: true, // Áp dụng cho Android
          useShouldOverrideUrlLoading: true, // Kích hoạt chặn điều hướng
          javaScriptCanOpenWindowsAutomatically: false, // Chặn JavaScript mở popup
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        onLoadStop: (controller, url) async {
          logger.d("Load done");
        },
      ),
    );
  }
}
