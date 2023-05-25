import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import './main.dart';

class MyWebViewWidget extends StatefulWidget {
  const MyWebViewWidget({super.key, required this.platform, required this.defaultUserAgent});
  final TargetPlatform? platform;
  final String? defaultUserAgent;

  @override
  State<MyWebViewWidget> createState() => _MyWebViewWidgetState();
}

class _MyWebViewWidgetState extends State<MyWebViewWidget>
    with WidgetsBindingObserver {

  final _key = UniqueKey();
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  late String url;
  double progress = 0;
  final Completer<InAppWebViewController> _controllerCompleter = Completer<
      InAppWebViewController>();
  int selectedIndex = 0;


  @override
  void initState() {
    super.initState();

    ///pull to refresh from inappwebview.....
    pullToRefreshController = kIsWeb ? null : PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Color(0xFF232F3E),
      ),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          webViewController?.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          webViewController?.loadUrl(
              urlRequest:
              URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }


  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(context) {
    return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                    child: Stack(
                        children: [
                          InAppWebView(
                            key: _key,
                            initialUrlRequest: URLRequest(
                                url: WebUri("https://coolkidz.lk")),

                            initialSettings: InAppWebViewSettings(
                              javaScriptCanOpenWindowsAutomatically: true,
                              useShouldOverrideUrlLoading: true,
                              mediaPlaybackRequiresUserGesture: false,
                              allowsInlineMediaPlayback: true,
                              allowsBackForwardNavigationGestures: true,
                              verticalScrollBarEnabled: false,
                              horizontalScrollBarEnabled: false,
                              useOnDownloadStart: true,
                              supportZoom: false,
                              disableContextMenu: true,
                              disableLongPressContextMenuOnLinks: true,
                              allowsLinkPreview: false,
                              mixedContentMode: MixedContentMode
                                  .MIXED_CONTENT_ALWAYS_ALLOW,

                              /// For social logins working... modifying the user agent as mobile web browser( instead of webview )
                              userAgent: Platform.isAndroid
                                  ? defaultUserAgent!.replaceFirst("; wv)", ")")
                                  : "${defaultUserAgent!} Safari/604.1",
                            ),


                            pullToRefreshController: pullToRefreshController,


                            onProgressChanged: (controller, progress) {
                              if (progress == 100) {
                                pullToRefreshController?.endRefreshing();
                              }
                              setState(() => this.progress = progress / 100);
                            },


                            onLoadStart: (controller, url) {
                              setState(() {
                                this.url = url.toString();
                              });
                            },


                            onLoadStop: (controller, url) async {
                              pullToRefreshController?.endRefreshing();

                              setState(() {
                                this.url = url.toString();
                              });
                            },

                            onWebViewCreated: (controller) {
                              webViewController = controller;
                              _controllerCompleter.complete(controller);
                            },

                            onPermissionRequest: (controller, request) async {
                              return PermissionResponse(
                                  resources: request.resources,
                                  action: PermissionResponseAction.GRANT);
                            },

                            shouldOverrideUrlLoading: (controller,
                                navigationAction) async {
                              var uri = navigationAction.request.url!;

                              /// keep this code here, if any situations, uncomment & try it.
                              // if (!["http", "https", "file", "chrome", "data", "javascript", "about"].contains(uri.scheme))
                              // {
                              //   if (await canLaunchUrl(uri)) {
                              //     await launchUrl(uri,);// Launch the App
                              //     return NavigationActionPolicy.CANCEL;// and cancel the request
                              //   }
                              // }

                              if ((uri.toString().contains("http:") && uri
                                  .toString().contains('coolkidz.lk'))
                                  || (uri.toString().contains("https:") && uri
                                      .toString().contains('coolkidz.lk'))) {
                                return NavigationActionPolicy.ALLOW;
                              }


                              else {
                                /// For helapay opened externally via it's app or Web browser.
                                if (uri.toString().contains("helapay.lk")) {
                                  await launchUrl(uri, mode: LaunchMode
                                      .externalApplication); //This is where external browser launches if a link is clicked
                                  return NavigationActionPolicy.CANCEL;
                                }

                                /// For homepage unwanted links opened externally via Web browser.
                                if (uri.toString().contains("ideageek.net")) {
                                  await launchUrl(uri, mode: LaunchMode
                                      .externalApplication); //This is where external browser launches if a link is clicked
                                  return NavigationActionPolicy.CANCEL;
                                }

                                if (uri.toString().contains(
                                    "mailto:") // Launch email app externally
                                    || uri.toString().contains(
                                        "tel:") // Launch phone dialer app externally
                                    || uri.toString().contains(
                                        "sms:") // Launch messaging app externally
                                ) {
                                  await launchUrl(uri,);
                                  return NavigationActionPolicy.CANCEL;
                                }

                                /// Social media Share ... This block is for sharing a product externally with a social media app
                                if (uri.toString().contains(
                                    'api.whatsapp.com') // this is for sharing applications should launches externally
                                    || uri.toString().contains(
                                        "twitter.com/intent") // this is for sharing applications should launches externally
                                    || uri.toString().contains(
                                        "twitter.com/share?") // this is for sharing applications should launches externally
                                    || uri.toString().contains(
                                        "facebook.com/sharer") // this is for sharing applications should launches externally
                                    || uri.toString().contains(
                                        "facebook.com/dialog/share?") // this is for sharing applications should launches externally
                                ) {
                                  await launchUrl(uri, mode: LaunchMode
                                      .externalApplication); //This is where sharing applications launches externally
                                  return NavigationActionPolicy.CANCEL;
                                }

                                /// For launching social apps externally with it's app or website
                                if ((uri.toString().contains('wa.me')) ||
                                    (uri.toString().contains(
                                        'api.whatsapp.com')) // Launching Whatsapp app externally
                                    || uri.toString().contains(
                                        "facebook.com") // Launching Facebook app externally
                                    || uri.toString().contains(
                                        "twitter.com") // Launching Twitter app externally
                                    || uri.toString().contains(
                                        "instagram.com") // Launching Instagram app externally
                                    || uri.toString().contains(
                                        "linkedin.com") // Launching linkedin app externally
                                    ||
                                    (uri.toString().contains("youtube.com")) ||
                                    (uri.toString().contains(
                                        "youtu.be")) // Launching Youtube app externally
                                    || uri.toString().contains(
                                        "tiktok.com") // Launching tiktok app externally
                                    || (uri.toString().contains("t.me")) ||
                                    (uri.toString().contains("telegram.me")) ||
                                    (uri.toString().contains(
                                        "telegram.dog")) // Launching Telegram app externally
                                    || uri.toString().contains(
                                        "reddit.com") // Launching reddit app externally
                                    || uri.toString().contains(
                                        "quora.com") // Launching quora app externally
                                    || uri.toString().contains(
                                        "pinterest.com") // Launching pinterest app externally
                                    || uri.toString().contains(
                                        "goo.gl") // Launching google maps app externally
                                ) {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                  return NavigationActionPolicy.CANCEL;
                                }
                              }

                              throw 'Could not launch $uri';
                            },


                            onReceivedError: (controller, request,
                                error) async {
                              pullToRefreshController?.endRefreshing();
                            },


                            ///Geo
                            onGeolocationPermissionsShowPrompt: (controller,
                                origin) async {
                              bool? result = await showDialog<bool>(
                                context: context,
                                barrierDismissible: false,
                                // user must tap button!
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                        'Allow This app to access your location while using the app?'),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: const <Widget>[
                                          Text(
                                              'Please allow us to access your location'),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Allow'),
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Denied'),
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (result!) {
                                return Future.value(
                                    GeolocationPermissionShowPromptResponse(
                                        origin: origin,
                                        allow: true,
                                        retain: true));
                              } else {
                                return Future.value(
                                    GeolocationPermissionShowPromptResponse(
                                        origin: origin,
                                        allow: false,
                                        retain: false));
                              }
                            },
                          ),
                        ])),
              ],
            ),
          ),
        ));
  }


  // Prevent app from exiting when back button pressed & implement a Alert dialog / Toast with double tap to exit
  Future<bool> onWillPop() async {
    DateTime currentTime = DateTime.now();
    if (await webViewController!.canGoBack()) {
      webViewController!.goBack();
      return Future.value(false);
    } else {
      showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: Text('Do you really want to exit the app?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    child: Text('Yes'),
                  ),
                ],
              ));

      return Future.value(true);
    }
  }

}