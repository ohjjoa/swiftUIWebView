//
//  ContentView.swift
//  webview
//
//  Created by 김태현 on 7/30/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var testViewModel = TestViewModel()
    @State private var isLoading = false
    @State private var shouldNavigate = true
    
    var body: some View {
        VStack {
//            if isLoading {
//                ProgressView()
//            } else {
//                WebView(url: URL(string: "https://www.naver.com")!, isLoading: $isLoading, messageHandler: { message in
//                    print("Received message: \(message)")
//                }, testViewModel: testViewModel)
//            }
            WebView(url: URL(string: "https://www.naver.com")!, isLoading: $isLoading, messageHandler: { message in
                print("Received message: \(message)")
            }, testViewModel: testViewModel, shouldNavigate: $shouldNavigate)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
