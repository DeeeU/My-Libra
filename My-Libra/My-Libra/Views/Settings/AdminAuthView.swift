//
//  AdminAuthView.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/16.
//

import SwiftUI

/// 管理者PIN認証画面（初回設定 / 認証）
struct AdminAuthView: View {
    @Environment(\.dismiss) private var dismiss

    let onAuthenticated: () -> Void

    @State private var adminAuth = AdminAuthManager.shared
    @State private var pin = ""
    @State private var confirmPin = ""
    @State private var isConfirming = false
    @State private var errorMessage: String?
    @State private var lockoutTimer: Timer?
    @State private var remainingSeconds = 0

    private var isSetupMode: Bool { !adminAuth.isSetUp }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // アイコン
                Image(systemName: isSetupMode ? "lock.badge.plus" : "lock.shield.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.accent)

                // タイトル
                VStack(spacing: 8) {
                    Text(titleText)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(subtitleText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                // PIN入力
                if adminAuth.isLockedOut {
                    lockoutView
                } else {
                    pinInputView
                }

                // エラーメッセージ
                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                }

                Spacer()
                Spacer()
            }
            .padding(.horizontal, 40)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
            }
            .onDisappear {
                lockoutTimer?.invalidate()
            }
        }
    }

    // MARK: - Sub Views

    private var pinInputView: some View {
        VStack(spacing: 16) {
            // PIN表示ドット
            HStack(spacing: 16) {
                let currentPin = isConfirming ? confirmPin : pin
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(index < currentPin.count ? Color.accentColor : Color(.systemGray4))
                        .frame(width: 14, height: 14)
                }
            }
            .animation(.easeInOut(duration: 0.15), value: isConfirming ? confirmPin : pin)

            // テンキー
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(1...9, id: \.self) { number in
                    pinButton(String(number))
                }
                pinButton("") // 空白
                pinButton("0")
                deleteButton
            }
        }
    }

    private var lockoutView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.lock.fill")
                .font(.system(size: 36))
                .foregroundStyle(.red)
            Text("ロックアウト中")
                .font(.headline)
                .foregroundStyle(.red)
            Text("残り \(formatTime(remainingSeconds))")
                .font(.title3)
                .fontWeight(.medium)
                .monospacedDigit()
            Text("認証の失敗回数が上限に達しました")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .onAppear { startLockoutTimer() }
    }

    private func pinButton(_ value: String) -> some View {
        Button {
            guard value.count == 1 else { return }
            appendDigit(value)
        } label: {
            if value.isEmpty {
                Color.clear
                    .frame(width: 72, height: 72)
            } else {
                Text(value)
                    .font(.title)
                    .fontWeight(.medium)
                    .frame(width: 72, height: 72)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
        }
        .disabled(value.isEmpty)
    }

    private var deleteButton: some View {
        Button {
            if isConfirming {
                if !confirmPin.isEmpty { confirmPin.removeLast() }
            } else {
                if !pin.isEmpty { pin.removeLast() }
            }
            errorMessage = nil
        } label: {
            Image(systemName: "delete.backward")
                .font(.title2)
                .frame(width: 72, height: 72)
        }
    }

    // MARK: - Logic

    private var titleText: String {
        if isSetupMode {
            return isConfirming ? "PINを再入力" : "管理者PINを設定"
        }
        return "管理者認証"
    }

    private var subtitleText: String {
        if isSetupMode {
            return isConfirming ? "確認のため同じPINを入力してください" : "6桁の数字を入力してください"
        }
        return "管理ダッシュボードにアクセスするには\n管理者PINを入力してください"
    }

    private func appendDigit(_ digit: String) {
        errorMessage = nil

        if isSetupMode {
            if isConfirming {
                confirmPin += digit
                if confirmPin.count == 6 { handleConfirmSetup() }
            } else {
                pin += digit
                if pin.count == 6 { handleSetupFirstEntry() }
            }
        } else {
            pin += digit
            if pin.count == 6 { handleAuthenticate() }
        }
    }

    private func handleSetupFirstEntry() {
        withAnimation {
            isConfirming = true
        }
    }

    private func handleConfirmSetup() {
        if pin == confirmPin {
            if adminAuth.setupPIN(pin) {
                onAuthenticated()
                dismiss()
            } else {
                withAnimation {
                    errorMessage = "PINの保存に失敗しました"
                    resetInput()
                }
            }
        } else {
            withAnimation {
                errorMessage = "PINが一致しません。最初からやり直してください"
                resetInput()
            }
        }
    }

    private func handleAuthenticate() {
        if adminAuth.authenticate(pin: pin) {
            onAuthenticated()
            dismiss()
        } else {
            withAnimation {
                if adminAuth.isLockedOut {
                    startLockoutTimer()
                } else {
                    let remaining = 5 - adminAuth.failedAttempts
                    errorMessage = "PINが正しくありません（残り\(remaining)回）"
                }
                pin = ""
            }
        }
    }

    private func resetInput() {
        pin = ""
        confirmPin = ""
        isConfirming = false
    }

    // MARK: - Lockout Timer

    private func startLockoutTimer() {
        remainingSeconds = adminAuth.remainingLockoutSeconds
        lockoutTimer?.invalidate()
        lockoutTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                remainingSeconds = adminAuth.remainingLockoutSeconds
                if !adminAuth.isLockedOut {
                    lockoutTimer?.invalidate()
                    resetInput()
                }
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let min = seconds / 60
        let sec = seconds % 60
        return String(format: "%d:%02d", min, sec)
    }
}
