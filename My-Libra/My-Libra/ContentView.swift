//
//  ContentView.swift
//  My-Libra
//
//  Created by kanabuchi on 2025/10/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Hello World")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("My-Libra")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("趣味・コレクション品の売買履歴管理アプリ")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
