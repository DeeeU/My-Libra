//
//  StoreKitService.swift
//  My-Libra
//
//  Created by Claude Code on 2026/02/13.
//

import StoreKit

@MainActor
@Observable
final class StoreKitService {

    static let productIDs: Set<String> = [
        "com.deeu.mylibra.pro.monthly",
        "com.deeu.mylibra.pro.yearly"
    ]

    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    private var transactionListener: Task<Void, Never>?

    var monthlyProduct: Product? {
        products.first { $0.id == "com.deeu.mylibra.pro.monthly" }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == "com.deeu.mylibra.pro.yearly" }
    }

    var hasActiveSubscription: Bool {
        !purchasedProductIDs.isEmpty
    }

    init() {
        transactionListener = listenForTransactions()
    }

    // Note: transactionListener runs for the app's entire lifetime (singleton pattern)

    // MARK: - Load Products

    func loadProducts() async {
        do {
            products = try await Product.products(for: Self.productIDs)
                .sorted { $0.price < $1.price }
        } catch {
            print("⚠️ 商品の読み込みエラー: \(error)")
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updateCurrentEntitlements()
            return transaction

        case .userCancelled:
            return nil

        case .pending:
            return nil

        @unknown default:
            return nil
        }
    }

    // MARK: - Restore

    func restorePurchases() async {
        try? await AppStore.sync()
        await updateCurrentEntitlements()
    }

    // MARK: - Entitlements

    func updateCurrentEntitlements() async {
        var activeIDs: Set<String> = []

        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                if transaction.revocationDate == nil {
                    activeIDs.insert(transaction.productID)
                }
            }
        }

        purchasedProductIDs = activeIDs
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if let self, let transaction = try? await self.checkVerified(result) {
                    await transaction.finish()
                    await self.updateCurrentEntitlements()
                }
            }
        }
    }

    // MARK: - Verification

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "トランザクションの検証に失敗しました"
        }
    }
}
