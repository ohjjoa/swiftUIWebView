//
//  WebView.swift
//  webview
//
//  Created by 김태현 on 7/30/24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    var messageHandler: ((String) -> Void)?
    var testViewModel: TestViewModel
    @Binding var shouldNavigate: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            self,
            messageHandler: messageHandler,
            testViewModel: testViewModel,
            shouldNavigate: $shouldNavigate
        )
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        let contentController = webView.configuration.userContentController
        contentController.add(context.coordinator, name: "callTest")
        contentController.add(context.coordinator, name: "moveTest")
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView
        var messageHandler: ((String) -> Void)?
        var testViewModel: TestViewModel
        @Binding var shouldNavigate: Bool
        
        init(_ parent: WebView, messageHandler: ((String) -> Void)?, testViewModel: TestViewModel, shouldNavigate: Binding<Bool>) {
            self.parent = parent
            self.messageHandler = messageHandler
            self.testViewModel = testViewModel
            self._shouldNavigate = shouldNavigate
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            sendAppVersionToWebView(webView)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            
            // 보내서 웹이 처리
            if message.name == "callTest" {
                if let bodyDict = message.body as? [String: Any] {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: bodyDict, options: [])
                        let decoder = JSONDecoder()
                        let testModel = try decoder.decode(TestModel.self, from: jsonData)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.testViewModel.identityVerificationStep1(
                                name: testModel.name,
                                identity: testModel.identity,
                                agency: testModel.agency,
                                phoneNumber: testModel.phoneNumber,
                                verifiType: "U"
                            )
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                } else {
                    print("Invalid messageBody type. Expected NSDictionary.")
                }
            }
            
            // 받아서 네이티브가 처리
            if message.name == "moveTest" {
                // 메시지 처리 로직을 여기에 작성
                DispatchQueue.main.async {
                    self.shouldNavigate = true
                }
            }
        }
        
        private func sendAppVersionToWebView(_ webView: WKWebView) {
            let appVersion = getAppVersion()
            let jsCode = "window.appVersion = '\(appVersion)';"
            
            webView.evaluateJavaScript(jsCode) { result, error in
                if let error = error {
                    print("Error injecting JavaScript: \(error)")
                } else {
                    print("App version injected successfully.")
                }
            }
        }
        
        func getAppVersion() -> String {
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                return version
            }
            return "Unknown"
        }
    }
}
