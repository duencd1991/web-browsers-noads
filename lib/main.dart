import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

void main() {
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
  String currentLink = "https://truyenfull.io";
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    readMyNoteInSharedPreferences();
  }

  Future<void> readMyNoteInSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedLink = prefs.getString("current_link");
    setState(() {
      currentLink = savedLink ?? "https://truyenfull.io";
    });
    logger.d("Load currentLink: $savedLink");
    _webViewController.loadUrl(
        urlRequest: URLRequest(url: WebUri(currentLink)));
  }

  Future<void> _saveCurrentLink(String text) async {
    logger.d("Save page $text");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("current_link", text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Expanded(
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
                  _webViewController.loadUrl(
                      urlRequest: URLRequest(url: WebUri(value)));
                  _saveCurrentLink(value);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Saved page!")),
                  );
                } else {
                  logger.d("URL $value invalid");
                }
              },
            ),
          ),
        ),
        body: Stack(
          children: [
            InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(currentLink)),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: false,
                  clearCache: true,
                  userAgent: "CustomUserAgent",
                  useHybridComposition: true, // Áp dụng cho Android
                  useShouldOverrideUrlLoading:
                  true, // Kích hoạt chặn điều hướng
                  javaScriptCanOpenWindowsAutomatically:
                  false, // Chặn JavaScript mở popup
                ),
                onWebViewCreated: (controller) {
                  logger.d("onWebViewCreated");
                  _webViewController = controller;
                },
                onLoadStop: (controller, url) async {
                  logger.d("onLoadStop: $url");
                }),
            Positioned(
                right: 16.0,
                bottom: 32.0,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: FloatingActionButton(
                      child: const Icon(Icons.bookmarks),
                      onPressed: () async {
                        Uri? url = await _webViewController.getOriginalUrl();
                        String currentUrl = url.toString();
                        logger.d("onPressed FAB url=$currentUrl");
                        // _saveCurrentLink(url?.toString() ?? "");
                      }),
                )
            ),
          ],
        ),
        );
  }
}
