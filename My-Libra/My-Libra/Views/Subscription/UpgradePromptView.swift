//
//  UpgradePromptView.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/13.
//

import SwiftUI

struct UpgradePromptView: View {
    let feature: ProFeature
    let showPaywall: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.title2)
                .foregroundStyle(.yellow)

            Text(feature.lockedMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showPaywall()
            } label: {
                Text("Pro にアップグレード")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    UpgradePromptView(feature: .statistics) {}
}
