//
//  DexOrderBookInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol DexOrderBookInteractorProtocol {

    func bidsAsks(_ pair: DexTraderContainer.DTO.Pair) -> Observable<(bids: [DexOrderBook.DTO.BidAsk], asks: [DexOrderBook.DTO.BidAsk])>
    
}
