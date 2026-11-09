//
//  ItemViewModel.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/11.
//

import Foundation

enum SortOption: String, CaseIterable {
    case dateDesc = "購入日（新しい順）"
    case dateAsc = "購入日（古い順）"
    case priceDesc = "価格（高い順）"
    case priceAsc = "価格（安い順）"
    case name = "名前順"
}

@Observable
final class ItemViewModel {
    var searchText = ""
    var selectedCategory: String = "すべて"
    var selectedStatus: ItemStatus? = nil
    var sortOption: SortOption = .dateDesc

    func filteredItems(from items: [Item]) -> [Item] {
        let filtered = items.filter { item in
            if let status = selectedStatus, item.status != status {
                return false
            }

            let categoryMatch = selectedCategory == "すべて" || item.category == selectedCategory
            let searchMatch = searchText.isEmpty || item.name.localizedCaseInsensitiveContains(searchText)

            return categoryMatch && searchMatch
        }

        return sorted(filtered)
    }

    func sorted(_ items: [Item]) -> [Item] {
        switch sortOption {
        case .dateDesc:
            return items.sorted { $0.purchaseDate > $1.purchaseDate }
        case .dateAsc:
            return items.sorted { $0.purchaseDate < $1.purchaseDate }
        case .priceDesc:
            return items.sorted { $0.purchasePrice > $1.purchasePrice }
        case .priceAsc:
            return items.sorted { $0.purchasePrice < $1.purchasePrice }
        case .name:
            return items.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        }
    }
}
