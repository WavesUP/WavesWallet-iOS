//
//  AssetViewPresenter.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxFeedback
import RxSwift

final class AssetDetailPresenter: AssetDetailPresenterProtocol {

    private var disposeBag: DisposeBag = DisposeBag()
    
    var interactor: AssetDetailInteractorProtocol!
    weak var moduleOutput: AssetDetailModuleOutput?

    let input: AssetDetailModuleInput

    init(input: AssetDetailModuleInput) {
        self.input = input
    }

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(assetsQuery())
        newFeedbacks.append(transactionsQuery())

        let initialState = self.initialState(input: input)

        let system = Driver.system(initialState: initialState,
                                   reduce: { [weak self] state, event -> AssetDetailTypes.State in

                                        guard let self = self else { return state }
                                        return self.reduce(state: state, event: event)
                                    },
                                   feedback: newFeedbacks)

        system
            .drive()
            .disposed(by: disposeBag)
    }

    private func assetsQuery() -> Feedback {
        return react(request: { state -> Bool? in
            return state.displayState.isAppeared == true
        }, effects: { [weak self] _ -> Signal<AssetDetailTypes.Event> in

            // TODO: Error
            guard let self = self else { return Signal.empty() }
            let ids = self.input.assets.map { $0.id }

            return self
                .interactor
                .assets(by: ids)
                .map { AssetDetailTypes.Event.setAssets($0) }
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }

    private struct TransactionsQuery: Hashable {
        let id: String
    }

    private func transactionsQuery() -> Feedback {
        return react(request: { state -> TransactionsQuery? in

            guard state.displayState.isAppeared == true else { return nil }
            guard state.transactionStatus.isLoading == true else { return nil }

            return TransactionsQuery(id: state.displayState.currentAsset.id)

        }, effects: { [weak self] query -> Signal<AssetDetailTypes.Event> in

            // TODO: Error
            guard let self = self else { return Signal.empty() }

            return self
                .interactor.transactions(by: query.id)
                .map { AssetDetailTypes.Event.setTransactions($0) }
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }
}

// MARK: Core State

private extension AssetDetailPresenter {

    func reduce(state: AssetDetailTypes.State, event: AssetDetailTypes.Event) -> AssetDetailTypes.State {

        switch event {
        case .tapTransaction(let tx):
            if case .transaction(let transactions) = state.transactionStatus {
                let index = transactions.enumerated().first {
                    $0.element.id == tx.id
                }?.offset ?? 0

                self.moduleOutput?.showTransaction(transactions: transactions, index: index)
            }

        case .tapHistory:
            self.moduleOutput?.showHistory(by: state.displayState.currentAsset.id)
            
        case .readyView:

            return state.mutate {
                $0.displayState = $0.displayState.mutate {
                    $0.isAppeared = true
                    $0.action = .refresh
                }
            }

        case .refreshing:

            let ids = state.assets.map { $0.info.id }
            interactor.refreshAssets(by: ids)

            return state.mutate {
                $0.displayState = $0.displayState.mutate {
                    $0.isRefreshing = true
                    $0.action = .none
                }
            }

        case .changedAsset(let assetId):

            return state.mutate(transform: { state in

                if state.displayState.currentAsset.id == assetId {
                    state.displayState.action = .none
                    return
                }

                let currentAsset = state.assets.first(where: { $0.info.id == assetId })
                if let currentAsset = currentAsset {
                    state.transactionStatus = .loading
                    state.displayState.currentAsset = currentAsset.info
                    state.displayState.sections = mapTosections(from: currentAsset,
                                                                and: state.transactionStatus)
                    state.displayState.isFavorite = currentAsset.info.isFavorite
                    state.displayState.isDisabledFavoriteButton = currentAsset.info.isSpam
                    state.displayState.action = .changedCurrentAsset
                } else {
                    state.displayState.action = .none
                }
            })

        case .setTransactions(let transactions):

            return state.mutate {

                let currentAsset = state.assets.first(where: { asset -> Bool in
                    return asset.info.id == state.displayState.currentAsset.id
                })

                if let asset = currentAsset {
                    $0.transactionStatus = transactions.count == 0 ? .empty : .transaction(transactions)

                    $0.displayState.sections = mapTosections(from: asset,
                                                             and: $0.transactionStatus)
                    $0.displayState.action = .refresh
                } else {
                    $0.displayState.action = .none
                }
            }

        case .setAssets(let assets):

            return state.mutate { state in

                var newAssets = assets
                
                let currentAssetIndex = state.displayState.assets.index(where: {$0.id == state.displayState.currentAsset.id})
                
                var asset = newAssets.first(where: { asset -> Bool in
                    return asset.info.id == state.displayState.currentAsset.id
                })

                if asset == nil {
                    if let index = currentAssetIndex {
                        let emptyAsset = state.displayState.currentAsset.emptyAssetBalance()
                        asset = emptyAsset
                        newAssets.insert(emptyAsset, at: index)
                    }
                    else {
                        asset = newAssets.first
                    }
                }

                if let asset = asset {
                    state.transactionStatus = .loading
                    state.displayState.sections = mapTosections(from: asset,
                                                                and: state.transactionStatus)

                    state.displayState.currentAsset = asset.info
                    state.displayState.isFavorite = asset.info.isFavorite
                    state.displayState.isDisabledFavoriteButton = asset.info.isSpam
                    state.displayState.isUserInteractionEnabled = true
                    state.displayState.action = .refresh
                } else {
                    state.transactionStatus = .none
                    state.displayState.sections = []
                    state.displayState.action = .none
                }
                state.displayState.isRefreshing = false
                state.displayState.assets = newAssets.map { $0.info }
                state.assets = newAssets
            }

        case .tapFavorite(let on):

            interactor.toggleFavoriteFlagForAsset(by: state.displayState.currentAsset.id, isFavorite: on)

            return state.mutate {
                
                if let index = state.assets.index(where: {$0.info.id == state.displayState.currentAsset.id}) {
                    $0.assets[index].info.isFavorite = on
                }
                
                $0.displayState.isFavorite = on
                $0.displayState.action = .changedFavorite
            }

        case .showReceive(let assetBalance):
            moduleOutput?.showReceive(asset: assetBalance)
            return state.mutate {
                $0.displayState.action = .none
            }
            
        case .showSend(let assetBalance):
            moduleOutput?.showSend(asset: assetBalance)
            return state.mutate {
                $0.displayState.action = .none
            }
            
        case .tapBurn(let asset, let delegate):
            moduleOutput?.showBurn(asset: asset, delegate: delegate)
            return state.mutate {
                $0.displayState.action = .none
            }
            
        default:
            break
        }

        return state.mutate {
            $0.displayState = $0.displayState.mutate {
                $0.action = .none
            }
        }
    }
}

// MARK: Map
extension AssetDetailPresenter {

    func mapTosections(from asset: AssetDetailTypes.DTO.Asset,
                             and transactionStatus: AssetDetailTypes.State.TransactionStatus) -> [AssetDetailTypes.ViewModel.Section]
    {

        var balance: AssetDetailTypes.ViewModel.Section!
        if asset.info.isSpam {
            balance = .init(kind: .none, rows: [.spamBalance(asset.balance), .tokenBurn(asset.info)])
        }
        else {
            balance = .init(kind: .none, rows: [.balance(asset.balance)])
        }
        
        var infoRows: [AssetDetailTypes.ViewModel.Row] = [.assetInfo(asset.info)]
        if !asset.info.isSpam && !asset.info.isWaves && asset.info.assetBalance.availableBalance > 0 {
            infoRows.append(.tokenBurn(asset.info))
        }
        let assetInfo: AssetDetailTypes.ViewModel.Section = .init(kind: .none, rows: infoRows)

        var transactionRows: [AssetDetailTypes.ViewModel.Row] = []
        var transactionHeaderTitle: String = ""

        switch transactionStatus {
        case .empty:
            transactionHeaderTitle = Localizable.Waves.Asset.Header.notHaveTransactions
            transactionRows = [.viewHistoryDisabled]

        case .loading:
            transactionHeaderTitle = Localizable.Waves.Asset.Header.lastTransactions
            transactionRows = [.transactionSkeleton]

        case .transaction(let transactions):
            transactionHeaderTitle = Localizable.Waves.Asset.Header.lastTransactions
            transactionRows = [.lastTransactions(transactions), .viewHistory]

        case .none:
            break
        }

        let transactions: AssetDetailTypes.ViewModel.Section = .init(kind: .title(transactionHeaderTitle),
                                                               rows: transactionRows)

        return [balance,
                transactions,
                assetInfo]

    }
}

// MARK: UI State

private extension AssetDetailPresenter {

    func initialState(input: AssetDetailModuleInput) -> AssetDetailTypes.State {
        return AssetDetailTypes.State(assets: [],
                                transactionStatus: .none,
                                displayState: initialDisplayState(input: input))
    }

    func initialDisplayState(input: AssetDetailModuleInput) -> AssetDetailTypes.DisplayState {

        let balances = AssetDetailTypes.ViewModel.Section.init(kind: .none, rows: [.balanceSkeleton])
        let transactions = AssetDetailTypes.ViewModel.Section.init(kind: .skeletonTitle, rows: [.transactionSkeleton, .viewHistorySkeleton])

        return AssetDetailTypes.DisplayState(isAppeared: false,
                                       isRefreshing: false,
                                       isFavorite: false,
                                       isDisabledFavoriteButton: false,
                                       isUserInteractionEnabled: false,
                                       currentAsset: input.currentAsset,
                                       assets: input.assets,
                                       sections: [balances,
                                                  transactions],
                                       action: .refresh)
    }
}

fileprivate extension AssetDetailTypes.DTO.Asset.Info {
    
    func emptyAssetBalance() -> AssetDetailTypes.DTO.Asset {

        let decimals = assetBalance.asset.precision
        
        let totalMoney = Money(0, decimals)
        let availableMoney = Money(0, decimals)
        let leasedMoney = Money(0, decimals)
        let inOrderMoney = Money(0, decimals)

        let newBalance = AssetDetailTypes.DTO.Asset.Balance(totalMoney: totalMoney,
                                                      avaliableMoney: availableMoney,
                                                      leasedMoney: leasedMoney,
                                                      inOrderMoney: inOrderMoney,
                                                      isFiat: isFiat)
        
        let newSmartBalance = DomainLayer.DTO.SmartAssetBalance(assetId: assetBalance.assetId,
                                                                totalBalance: 0,
                                                                leasedBalance: 0,
                                                                inOrderBalance: 0,
                                                                settings: assetBalance.settings,
                                                                asset: assetBalance.asset,
                                                                modified: assetBalance.modified,
                                                                sponsorBalance: assetBalance.sponsorBalance)
        var info = self
        info.assetBalance = newSmartBalance
        return AssetDetailTypes.DTO.Asset(info: info, balance: newBalance)
    }
}
