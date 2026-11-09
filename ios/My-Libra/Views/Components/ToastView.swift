//
//  ToastView.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/11.
//

import SwiftUI

enum ToastStyle {
    case success
    case error
    case info

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .info: return .blue
        }
    }
}

struct ToastView: View {
    let message: String
    let style: ToastStyle

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: style.icon)
                .foregroundStyle(style.color)
            Text(message)
                .font(.subheadline)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
    }
}

struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let style: ToastStyle

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if isPresented {
                    ToastView(message: message, style: style)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation {
                                    isPresented = false
                                }
                            }
                        }
                        .zIndex(1)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isPresented)
    }
}

extension View {
    func toast(isPresented: Binding<Bool>, message: String, style: ToastStyle = .success) -> some View {
        modifier(ToastModifier(isPresented: isPresented, message: message, style: style))
    }
}

#Preview {
    VStack {
        ToastView(message: "保存しました", style: .success)
        ToastView(message: "エラーが発生しました", style: .error)
        ToastView(message: "情報メッセージ", style: .info)
    }
}
