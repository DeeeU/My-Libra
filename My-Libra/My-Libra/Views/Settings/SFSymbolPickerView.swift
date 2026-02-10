//
//  SFSymbolPickerView.swift
//  My-Libra
//
//  Created by Claude Code on 2025/02/11.
//

import SwiftUI

struct SFSymbolPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""

    private let columns = [GridItem(.adaptive(minimum: 50))]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filteredSymbols, id: \.self) { symbol in
                        Button {
                            selectedIcon = symbol
                            dismiss()
                        } label: {
                            Image(systemName: symbol)
                                .font(.title2)
                                .frame(width: 44, height: 44)
                                .background(
                                    selectedIcon == symbol
                                        ? Color.accentColor.opacity(0.2)
                                        : Color(UIColor.systemGray6)
                                )
                                .cornerRadius(8)
                                .foregroundStyle(
                                    selectedIcon == symbol
                                        ? Color.accentColor
                                        : .primary
                                )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("アイコンを選択")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "アイコンを検索")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var filteredSymbols: [String] {
        if searchText.isEmpty {
            return Self.availableSymbols
        }
        return Self.availableSymbols.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    // MARK: - Available Symbols

    static let availableSymbols: [String] = [
        // 一般
        "star.fill", "heart.fill", "tag.fill", "bookmark.fill",
        "bag.fill", "cart.fill", "gift.fill", "cube.box.fill",
        // ホビー・コレクション
        "rectangle.portrait.on.rectangle.portrait", "figure.stand",
        "gamecontroller.fill", "book.fill", "film.fill",
        "music.note", "paintbrush.fill", "theatermasks.fill",
        "puzzlepiece.fill", "trophy.fill", "ticket.fill",
        // ファッション
        "shoe.fill", "tshirt.fill", "eyeglasses",
        // テクノロジー
        "iphone", "desktopcomputer", "headphones",
        "watch.analog", "camera.fill", "tv.fill",
        // スポーツ
        "football.fill", "basketball.fill", "tennisball.fill",
        "bicycle", "figure.run",
        // 金融・ビジネス
        "creditcard.fill", "banknote.fill", "chart.line.uptrend.xyaxis",
        // 自然・その他
        "leaf.fill", "flame.fill", "globe.asia.australia.fill",
        "flag.fill", "wrench.fill", "scissors",
        "paintpalette.fill", "clock.fill",
        "car.fill", "airplane",
        // 食べ物
        "cup.and.saucer.fill", "fork.knife",
        // その他
        "square.grid.2x2.fill", "folder.fill", "archivebox.fill",
        "shippingbox.fill", "doc.fill", "photo.fill",
    ]
}

#Preview {
    SFSymbolPickerView(selectedIcon: .constant("star.fill"))
}
