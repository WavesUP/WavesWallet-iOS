//
//  MarketPulseWidgetInteractor.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 24.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDK
import DomainLayer
import WavesSDKExtensions
import Extensions

private enum Constants {
    static let exchangeTxLimit: Int = 5
}

protocol MarketPulseWidgetInteractorProtocol {
    func assets() -> Observable<[MarketPulse.DTO.Asset]>
    func chachedAssets() -> Observable<[MarketPulse.DTO.Asset]>
    func settings() -> Observable<MarketPulse.DTO.Settings>
}

final class MarketPulseWidgetInteractor: MarketPulseWidgetInteractorProtocol {
  
    private let widgetSettingsRepository: WidgetSettingsInizializationUseCaseProtocol = WidgetSettingsInizialization()
    private let pairsPriceRepository: WidgetPairsPriceRepositoryProtocol = WidgetPairsPriceRepositoryRemote()
    private let dbRepository: MarketPulseDataBaseRepositoryProtocol = MarketPulseDataBaseRepository()
    private let transactionsRepository: WidgetTransactionsRepositoryProtocol = WidgetTransactionsRepositoryRemote()
    
    init() {
        _ = setupLayers()
    }
    
    static var shared: MarketPulseWidgetInteractor = MarketPulseWidgetInteractor()
    
    private func setupLayers() -> Bool {
    
        guard let googleServiceInfoPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            return false
        }
        
        guard let appsflyerInfoPath = Bundle.main.path(forResource: "Appsflyer-Info", ofType: "plist") else {
            return false
        }
        
        guard let amplitudeInfoPath = Bundle.main.path(forResource: "Amplitude-Info", ofType: "plist") else {
            return false
        }

        WidgetAnalyticManagerInitialization.setup(resources: .init(googleServiceInfo: googleServiceInfoPath,
            appsflyerInfo: appsflyerInfoPath,
            amplitudeInfo: amplitudeInfoPath))
        
        return true
    }
    
    func settings() -> Observable<MarketPulse.DTO.Settings> {
        
        return Observable.zip(WidgetSettings.rx.currency(),
                              widgetSettingsRepository.settings())
            .flatMap({ (currency, marketPulseSettings) -> Observable<MarketPulse.DTO.Settings> in
                return Observable.just(MarketPulse.DTO.Settings(currency: currency,
                                                                isDarkMode: marketPulseSettings.isDarkStyle,
                                                                inverval: marketPulseSettings.interval))
            })
    }
    
    func chachedAssets() -> Observable<[MarketPulse.DTO.Asset]> {
        return dbRepository.chachedAssets()
    }
    
    func assets() -> Observable<[MarketPulse.DTO.Asset]> {
        
        return widgetSettingsRepository.settings()
            .flatMap({ [weak self] (settings) -> Observable<[MarketPulse.DTO.Asset]> in
                
                guard let self = self else { return Observable.empty() }
                
                var assets = settings.assets
                
                let iconStyle = AssetLogo.Icon.init(assetId: "",
                                                    name: "",
                                                    url: nil,
                                                    isSponsored: false,
                                                    hasScript: false)
                
                assets.append(.init(id: MarketPulse.usdAssetId,
                                    name: "",
                                    icon: iconStyle,
                                    amountAsset: WavesSDKConstants.wavesAssetId,
                                    priceAsset: MarketPulse.usdAssetId))
                
                assets.append(.init(id: MarketPulse.eurAssetId,
                                    name: "",
                                    icon: iconStyle,
                                    amountAsset: WavesSDKConstants.wavesAssetId,
                                    priceAsset: MarketPulse.eurAssetId))
                
                return self.loadAssets(assets: assets)
            })
    }
    
    private func loadAssets(assets: [DomainLayer.DTO.MarketPulseSettings.Asset]) -> Observable<[MarketPulse.DTO.Asset]> {
        
        var arrayExchangeTx: [Observable<[DataService.DTO.ExchangeTransaction]>] = []

        for asset in assets {
            arrayExchangeTx.append(transactionsRepository.exchangeTransactions(amountAsset: asset.amountAsset, priceAsset: asset.priceAsset, limit: Constants.exchangeTxLimit))
        }
        
        let query = assets.map { DomainLayer.Query.Dex.SearchPairs.Pair.init(amountAsset: $0.amountAsset,
                                                                             priceAsset: $0.priceAsset) }
    
        return pairsPriceRepository
            .searchPairs(.init(kind: .pairs(query)))
            .flatMap { (searchResult) -> Observable<[MarketPulse.DTO.Asset]> in

                return Observable.zip(arrayExchangeTx)
                    .flatMap({ [weak self] (arrayTx) -> Observable<[MarketPulse.DTO.Asset]> in

                    guard let self = self else { return Observable.empty() }
                    
                    var pairs: [MarketPulse.DTO.Asset] = []
                    
                    for (index, model) in searchResult.pairs.enumerated() {
                        
                        let exchangeAssetTxs = arrayTx[index]
                        
                        let sumPriceAmount = exchangeAssetTxs.map{$0.amount * $0.price}.reduce(0, {$0 + $1})
                        let sumAmount = exchangeAssetTxs.map{$0.amount}.reduce(0, {$0 + $1})
                        let lastPrice = sumAmount > 0 ? sumPriceAmount / sumAmount : 0

                        let asset = assets[index]
                       
                        pairs.append(MarketPulse.DTO.Asset(id: asset.id,
                                                           name: asset.name,
                                                           icon: asset.icon,
                                                           firstPrice: model?.firstPrice ?? 0,
                                                           lastPrice: lastPrice,
                                                           volume: model?.volume ?? 0,
                                                           volumeWaves: model?.volumeWaves ?? 0,
                                                           quoteVolume: model?.quoteVolume ?? 0,
                                                           amountAsset: asset.amountAsset))
                    }
                    
                    return self.dbRepository.saveAsssets(assets: pairs)
                        .flatMap({ (_) -> Observable<[MarketPulse.DTO.Asset]> in
                            return Observable.just(pairs)
                        })
                })
                 
        }
    }
}

private struct AuthorizationInteractorLocalizableImp: AuthorizationInteractorLocalizableProtocol {
    
    var fallbackTitle: String {
        return ""
    }
    
    var cancelTitle: String {
        return ""
    }
    
    var readFromkeychain: String {
        return ""
    }
    
    var saveInkeychain: String {
        return ""
    }
}
