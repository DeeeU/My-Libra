//
//  LaunchScreenView.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/11.
//

import SwiftUI
import SwiftData

struct LaunchScreenView: View {
    @State private var isAnimating = false
    @State private var showText = false
    @State private var showContent = false
    @State private var beamAngle: Double = -15

    var body: some View {
        if showContent {
            ContentView()
        } else {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    BalanceScaleView(beamAngle: beamAngle)
                        .frame(width: 160, height: 160)
                        .opacity(isAnimating ? 1 : 0)

                    Text("My Libra")
                        .font(.title)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .opacity(showText ? 1 : 0)
                }
            }
            .onAppear {
                withAnimation(.easeIn(duration: 0.3)) {
                    isAnimating = true
                }

                withAnimation(.spring(duration: 2.0, bounce: 0.35).delay(0.3)) {
                    beamAngle = 0
                }

                withAnimation(.easeIn(duration: 0.5).delay(2.0)) {
                    showText = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showContent = true
                    }
                }
            }
        }
    }
}

#Preview {
    LaunchScreenView()
        .modelContainer(for: [Category.self, WishlistItem.self, Item.self], inMemory: true)
}
