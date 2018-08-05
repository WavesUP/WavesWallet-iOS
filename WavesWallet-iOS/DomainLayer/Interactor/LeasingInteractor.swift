//
//  LeasingInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya
import RealmSwift
import RxSwift
import RxSwiftExt

private struct Constants {
    static let durationInseconds: Double =  15
}

protocol LeasingInteractorProtocol {
    func activeLeasingTransactions(by accountAddress: String, isNeedUpdate: Bool) -> AsyncObservable<[DomainLayer.DTO.LeasingTransaction]>
}

final class LeasingInteractor: LeasingInteractorProtocol {

    private let leasingTransactionLocal: LeasingTransactionRepositoryProtocol = LeasingTransactionRepositoryLocal()
    private let leasingTransactionRemote: LeasingTransactionRepositoryProtocol = LeasingTransactionRepositoryRemote()

    func activeLeasingTransactions(by accountAddress: String, isNeedUpdate: Bool = false) -> AsyncObservable<[DomainLayer.DTO.LeasingTransaction]> {

            let local = leasingTransactionLocal.activeLeasingTransactions(by: accountAddress)
            return local.flatMap(weak: self) { owner, transactions -> Observable<[DomainLayer.DTO.LeasingTransaction]> in

                let now = Date()
                let isNeedForceUpdate = transactions.count == 0 || transactions.first { (now.timeIntervalSinceNow - $0.modified.timeIntervalSinceNow) > Constants.durationInseconds }  != nil || isNeedUpdate

                if isNeedForceUpdate {
                    info("From Remote", type: LeasingInteractor.self)
                } else {
                    info("From BD", type: LeasingInteractor.self)
                }

                guard isNeedForceUpdate == true else { return Observable.just(transactions) }

                return owner
                    .leasingTransactionRemote
                    .activeLeasingTransactions(by: accountAddress)
                    .flatMap(weak: owner, selector: { owner, transactions -> Observable<[DomainLayer.DTO.LeasingTransaction]> in
                        return owner.leasingTransactionLocal.saveLeasingTransactions(transactions).map({ _ -> [DomainLayer.DTO.LeasingTransaction] in
                            return transactions
                        })
                    })
                }
                .share()
                .observeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
        }
}
