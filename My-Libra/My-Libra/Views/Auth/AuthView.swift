//
//  AuthView.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/13.
//

import SwiftUI

struct AuthView: View {
    @Binding var isSkipped: Bool
    @State private var isLoginMode = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // App Logo
                VStack(spacing: 12) {
                    Image(systemName: "scalemass")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.accentColor)

                    Text("My Libra")
                        .font(.title)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                }
                .padding(.top, 40)

                // Login / Register
                if isLoginMode {
                    LoginView()
                } else {
                    RegisterView()
                }

                // Toggle
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isLoginMode.toggle()
                    }
                } label: {
                    Text(isLoginMode ? "アカウントをお持ちでない方はこちら" : "アカウントをお持ちの方はこちら")
                        .font(.subheadline)
                }

                Spacer()

                // Skip
                Button {
                    isSkipped = true
                } label: {
                    Text("ログインせずに使う")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    AuthView(isSkipped: .constant(false))
}
