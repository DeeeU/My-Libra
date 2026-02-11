//
//  BalanceScaleView.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/11.
//

import SwiftUI

struct BalanceScaleView: View {
    let beamAngle: Double

    var body: some View {
        Canvas { context, size in
            let centerX = size.width / 2
            let centerY = size.height * 0.55

            // 支柱
            let pillarWidth: CGFloat = 4
            let pillarHeight: CGFloat = size.height * 0.35
            let pillarRect = CGRect(
                x: centerX - pillarWidth / 2,
                y: centerY,
                width: pillarWidth,
                height: pillarHeight
            )
            context.fill(Path(roundedRect: pillarRect, cornerRadius: 2), with: .color(.primary))

            // 支点（三角形）
            let baseY = centerY + pillarHeight
            let triangleSize: CGFloat = 20
            var triangle = Path()
            triangle.move(to: CGPoint(x: centerX, y: baseY - triangleSize))
            triangle.addLine(to: CGPoint(x: centerX - triangleSize * 0.7, y: baseY))
            triangle.addLine(to: CGPoint(x: centerX + triangleSize * 0.7, y: baseY))
            triangle.closeSubpath()
            context.fill(triangle, with: .color(.primary))

            // ビーム
            let beamLength: CGFloat = size.width * 0.7
            let beamHeight: CGFloat = 4
            context.translateBy(x: centerX, y: centerY)
            context.rotate(by: .degrees(beamAngle))

            let beamRect = CGRect(
                x: -beamLength / 2,
                y: -beamHeight / 2,
                width: beamLength,
                height: beamHeight
            )
            context.fill(Path(roundedRect: beamRect, cornerRadius: 2), with: .color(.primary))

            // 鎖（左右の線）
            let chainLength: CGFloat = size.height * 0.15
            let panOffset = beamLength / 2

            // 左の鎖
            let leftChainStart = CGPoint(x: -panOffset, y: 0)
            let leftChainEnd = CGPoint(x: -panOffset, y: chainLength)
            var leftChain = Path()
            leftChain.move(to: leftChainStart)
            leftChain.addLine(to: leftChainEnd)
            context.stroke(leftChain, with: .color(.primary), lineWidth: 2)

            // 右の鎖
            let rightChainStart = CGPoint(x: panOffset, y: 0)
            let rightChainEnd = CGPoint(x: panOffset, y: chainLength)
            var rightChain = Path()
            rightChain.move(to: rightChainStart)
            rightChain.addLine(to: rightChainEnd)
            context.stroke(rightChain, with: .color(.primary), lineWidth: 2)

            // 左の皿
            let panWidth: CGFloat = size.width * 0.22
            let panDepth: CGFloat = 8
            var leftPan = Path()
            leftPan.move(to: CGPoint(x: -panOffset - panWidth / 2, y: chainLength))
            leftPan.addQuadCurve(
                to: CGPoint(x: -panOffset + panWidth / 2, y: chainLength),
                control: CGPoint(x: -panOffset, y: chainLength + panDepth)
            )
            context.stroke(leftPan, with: .color(.primary), lineWidth: 3)

            // 右の皿
            var rightPan = Path()
            rightPan.move(to: CGPoint(x: panOffset - panWidth / 2, y: chainLength))
            rightPan.addQuadCurve(
                to: CGPoint(x: panOffset + panWidth / 2, y: chainLength),
                control: CGPoint(x: panOffset, y: chainLength + panDepth)
            )
            context.stroke(rightPan, with: .color(.primary), lineWidth: 3)
        }
    }
}

#Preview {
    BalanceScaleView(beamAngle: 0)
        .frame(width: 200, height: 200)
}
