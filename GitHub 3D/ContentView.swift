//
//  ContentView.swift
//  GitHub 3D
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppStore()
    @AppStorage("auth.signedIn") private var isSignedIn = false

    var body: some View {
        Group {
            if isSignedIn {
                RootView(isSignedIn: $isSignedIn)
            } else {
                AuthFlowView(isSignedIn: $isSignedIn)
            }
        }
        .environmentObject(store)
    }
}

#Preview {
    ContentView()
}
