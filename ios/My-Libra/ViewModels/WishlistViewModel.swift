//
//  WishlistViewModel.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/11.
//

import Foundation

@Observable
final class WishlistViewModel {
    var searchText = ""
    var selectedCategory: String = "すべて"

    func filteredItems(from items: [WishlistItem]) -> [WishlistItem] {
        items.filter { item in
            guard !item.isPurchased else { return false }

            let categoryMatch = selectedCategory == "すべて" || item.category == selectedCategory
            let searchMatch = searchText.isEmpty || item.name.localizedCaseInsensitiveContains(searchText)

            return categoryMatch && searchMatch
        }
    }
}
