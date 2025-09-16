import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  bool _hasError = false;
  late final WebViewController webController;

  @override
  void initState() {
    super.initState();
    webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Optional: You could use this to update a linear progress indicator
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://jobs.academy'));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (await webController.canGoBack()) {
          webController.goBack();
          return;
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              // The WebView widget remains the same
              WebViewWidget(controller: webController),

              // Professional Loading UI
              if (_isLoading)
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor, // Fills the background with the theme color
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.deepPurple, // Custom color
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Loading content...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Professional Error UI
              if (_hasError)
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_off,
                          size: 100,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Network Error',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Could not connect to the internet. Please check your connection and try again.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () {
                            webController.reload();
                            setState(() {
                              _isLoading = true;
                              _hasError = false;
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reload Page'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// class HomePage extends StatelessWidget{
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
    
//     final webController = 
//       WebViewController()
//         ..setJavaScriptMode(JavaScriptMode.unrestricted)
//         ..loadRequest(Uri.parse('https://jobs.academy'));
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, result) async {
//         if (await webController.canGoBack()){
//           webController.goBack();
//           return;
//         }
//       },
//       child: Scaffold(
//       // appBar: AppBar(
//       //   // title: Text("Jobs Academy View")),
//       //   title: null,
//       //   // body: WebViewWidget(controller: webController),
//       // ),
//        body: SafeArea(
//           child: WebViewWidget(controller: webController),
//         ),
//       ),
//     );
    
    
//   }
// }