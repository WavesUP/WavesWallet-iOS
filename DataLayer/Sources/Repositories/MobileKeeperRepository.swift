//
//  MobileKeeperRepository.swift
//  DataLayer
//
//  Created by rprokofev on 01.09.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import RxSwift
import WavesSDK
import WavesSDKCrypto

//Rename to UseCase

public class MobileKeeperRepository: MobileKeeperRepositoryProtocol {
    
    private var repositoriesFactory: RepositoriesFactoryProtocol
    
    init(repositoriesFactory: RepositoriesFactoryProtocol) {
        self.repositoriesFactory = repositoriesFactory
        
        WavesKeeper.initialization(application: .init(name: "Waves",
                                                      iconUrl: "",
                                                      schemeUrl: "waves"))
    }
    public func prepareRequest(_ request: DomainLayer.DTO.MobileKeeper.Request,
                               signedWallet: DomainLayer.DTO.SignedWallet,
                               timestamp: Date) -> Observable<DomainLayer.DTO.MobileKeeper.PrepareRequest> {
        
        
        guard let signature = request.transactionSignature(signedWallet: signedWallet,
                                                           timestamp: timestamp) else {
                                                            //TODO: Error
            return Observable.never()
        }
        
        let prepareRequest = DomainLayer
            .DTO
            .MobileKeeper
            .PrepareRequest.init(request: request,
                                 timestamp: timestamp,
                                 proof: signature.bytesStructure,
                                 txId: signature.id,
                                 signedWallet: signedWallet)
        
        return Observable.just(prepareRequest)
    }
    
    public func completeRequest(_ prepareRequest: DomainLayer.DTO.MobileKeeper.PrepareRequest) -> Observable<DomainLayer.DTO.MobileKeeper.CompletedRequest> {
        
        let action = prepareRequest.request.action
        
        switch action {
        case .send:
            
            return repositoriesFactory
                .transactionsRepositoryRemote
                .send(by: prepareRequest.request.transaction,
                      wallet: prepareRequest.signedWallet)
                .flatMap({ (tx) -> Observable<DomainLayer.DTO.MobileKeeper.CompletedRequest> in
                    
                    let completedRequest = prepareRequest.completedRequest(response: .success(.send(tx)),
                                                                           signedWallet: prepareRequest.signedWallet)
                    return Observable.just(completedRequest)
                })
                .catchError({ (error) -> Observable<DomainLayer.DTO.MobileKeeper.CompletedRequest> in
                    
                    if let networkError = error as? NetworkError {
                        
                        let title = { () -> String in
                            switch networkError {
                            case .message(let message):
                                return message
                            default:
                                return ""
                            }
                        }()
                        
                        let completedRequest = prepareRequest.completedRequest(response: .error(.message(title, 0)),
                                                                               signedWallet: prepareRequest.signedWallet)
                        return Observable.just(completedRequest)
                    }
                    
                    let completedRequest = prepareRequest.completedRequest(response: .error(.reject),
                                                                           signedWallet: prepareRequest.signedWallet)
                    return Observable.just(completedRequest)
                })
            
        case .sign:
            
            let completedRequest = prepareRequest.completedRequest(response: .success(.sign(prepareRequest.request.transaction)),
                                                                   signedWallet: prepareRequest.signedWallet)
            return Observable.just(completedRequest)
        }
    }
    
    
    public func approveRequest(_ completedRequest: DomainLayer.DTO.MobileKeeper.CompletedRequest) {
        
      returnResponse(for: completedRequest.request.dApp,
                     response: completedRequest.response)
    }
    
    public func rejectRequest(_ request: DomainLayer.DTO.MobileKeeper.Request) {
        returnResponse(for: request.dApp,
                       response: .error(.reject))
    }
    
    
    //TODO: Pavel
    //TODO: Method For Wallet.
    public func decodableRequest(_ url: URL, sourceApplication: String) -> Observable<DomainLayer.DTO.MobileKeeper.Request?> {
        
        if let dataRequest = url.request {
            
            var tx: TransactionSenderSpecifications?
            
            switch dataRequest.transaction {
            case .transfer(let model):
                tx = .send(.init(recipient: model.recipient,
                                 assetId: model.assetId,
                                 amount: model.amount,
                                 fee: model.fee,
                                 attachment: model.attachment,
                                 feeAssetID: model.feeAssetId,
                                 chainId: model.chainId,
                                 timestamp: Date()))
                
            default:
                break
            }
            
            if let tx = tx {
                let request = DomainLayer.DTO.MobileKeeper.Request.init(dApp: .init(name: dataRequest.dApp.name,
                                                                                    iconUrl: dataRequest.dApp.iconUrl,
                                                                                    scheme: dataRequest.dApp.schemeUrl),
                                                                        action: dataRequest.action == .send ? .send : .sign,
                                                                        transaction: tx)
            }

        }
        
       let request = DomainLayer.DTO.MobileKeeper.Request.init(dApp: .init(name: "AppCon",
                                                                            iconUrl: "",
                                                                            scheme: "AplicationMega"),
                                                                action: .send,
                                                                transaction: .send(.init(recipient: "3PEsVWBVi4szBuJFTJ1dhYmULS4eH22sEUH",
                                                                                         assetId: "WAVES",
                                                                                         amount: 1000,
                                                                                         fee: 1000000,
                                                                                         attachment: "",
                                                                                         feeAssetID: "WAVES",
                                                                                         chainId: "W",
                                                                                         timestamp: Date())))
        
        return Observable.just(request)
    }
    
    //TODO: Pavel
    //TODO: Method For Wallet. Result Return for dApp
    public func returnResponse(for dApp: DomainLayer.DTO.MobileKeeper.Application,
                               response: DomainLayer.DTO.MobileKeeper.Response) {
        

        //        UIApplication.shared.open(URL.init(string: "\(dApp.schemeUrl)://arg1=3&arg2=4")!, options: .init(), completionHandler: nil)
    }
}
    

extension DomainLayer.DTO.MobileKeeper.Application {
    
    var wavesKeeperApplication: WavesKeeper.Application {
        return .init(name: name, iconUrl: iconUrl, schemeUrl: scheme)
    }
}


fileprivate extension NodeService.Query.Transaction.InvokeScript.Call {
    
    
    var argsSender: [InvokeScriptTransactionSender.Arg] {
        
        return self.args.map({ (arg) -> InvokeScriptTransactionSender.Arg in
            
            let value = { () -> InvokeScriptTransactionSender.Arg.Value in
                
                switch arg.value {
                case .binary(let value):
                    return .binary(value)
                    
                case .bool(let value):
                    return .bool(value)
                    
                case .integer(let value):
                    return .integer(value)
                    
                case .string(let value):
                    return .string(value)
                }
            }()
            
            return InvokeScriptTransactionSender.Arg(value: value)
        })
    }
    
    var callSender: InvokeScriptTransactionSender.Call {
        return InvokeScriptTransactionSender.Call(function: self.function,
                                                  args: self.argsSender)
    }
}

//TODO:
fileprivate extension TransactionSenderSpecifications {
    
    func nodeQuery(proof: Bytes, timestamp: Int64, publicKey: String) -> NodeService.Query.Transaction? {
        
        let proofs = [Base58Encoder.encode(proof)]
        
        switch self {
        case .send(let model):
            
            let transfer = NodeService.Query.Transaction.Transfer.init(recipient: model.recipient,
                                                                       assetId: model.assetId,
                                                                       amount: model.amount,
                                                                       fee: model.fee,
                                                                       attachment: model.attachment,
                                                                       feeAssetId: model.feeAssetID,
                                                                       timestamp: timestamp,
                                                                       senderPublicKey: publicKey,
                                                                       proofs: proofs,
                                                                       chainId: model.chainId ?? "")
            
            return .transfer(transfer)
            
        case .invokeScript(let model):
            return nil
            
            
        default:
            return nil
        }
    }
}


fileprivate extension DomainLayer.DTO.InvokeScriptTransaction {

    var invokeScriptTransactionNodeService: NodeService.DTO.InvokeScriptTransaction? {
                
        return NodeService.DTO.InvokeScriptTransaction(type: self.type,
                                                       id: self.id,
                                                       chainId: self.chainId,
                                                       sender: self.sender,
                                                       senderPublicKey: self.senderPublicKey,
                                                       fee: self.fee,
                                                       timestamp: self.timestamp,
                                                       proofs: self.proofs,
                                                       version: self.version,
                                                       height: self.height,
                                                       feeAssetId: self.feeAssetId,
                                                       dApp: self.dappAddress,
                                                       call: nil,
                                                       payment: [])
    }
    
}

fileprivate extension DomainLayer.DTO.AnyTransaction {
    
    var transactionNodeService: NodeService.DTO.Transaction? {
        
        switch self {
        case .transfer(let model):
            return NodeService.DTO.Transaction.transfer(.init(type: model.type,
                                                              id: model.id,
                                                              sender: model.sender,
                                                              senderPublicKey: model.senderPublicKey,
                                                              fee: model.fee,
                                                              timestamp: model.timestamp,
                                                              version: model.version,
                                                              height: model.height,
                                                              signature: model.signature,
                                                              proofs: model.proofs,
                                                              recipient: model.recipient,
                                                              assetId: model.assetId,
                                                              feeAssetId: model.feeAssetId,
                                                              amount: model.amount,
                                                              attachment: model.attachment))
            
        default:
            return nil
        }
    }
}


fileprivate extension NodeService.Query.Transaction.InvokeScript {
    
    var paymentSender: [InvokeScriptTransactionSender.Payment] {
        return self.payment.map { InvokeScriptTransactionSender.Payment.init(amount: $0.amount, assetId: $0.assetId) }
    }
}

fileprivate extension NodeService.Query.Transaction.Data {
    
    var valueSender: [DataTransactionSender.Value] {
        
        return self.data.map { (data) -> DataTransactionSender.Value in
            
            let kind = { () -> DataTransactionSender.Value.Kind in
                switch data.value {
                case .binary(let value):
                    return .binary(value)
                    
                case .boolean(let value):
                    return .boolean(value)
                    
                case .integer(let value):
                    return .integer(value)
                    
                case .string(let value):
                    return .string(value)
                }
            }()
            
            return DataTransactionSender.Value.init(key: data.key, value: kind)
        }
    }
}


fileprivate extension NodeService.Query.Transaction {
    
    var transactionSenderSpecifications: TransactionSenderSpecifications? {
        
        switch self {
        case .invokeScript(let model):
            
            let sender = InvokeScriptTransactionSender(fee: model.fee,
                                                       feeAssetId: model.feeAssetId,
                                                       dApp: model.dApp,
                                                       call: model.call?.callSender,
                                                       payment: model.paymentSender,
                                                       chainId: model.chainId,
                                                       timestamp: Date.init(milliseconds: model.timestamp))
            
            return .invokeScript(sender)
            
        case .transfer(let model):
            
            let sender = SendTransactionSender.init(recipient: model.recipient,
                                                    assetId: model.assetId,
                                                    amount: model.amount,
                                                    fee: model.fee,
                                                    attachment: model.attachment,
                                                    feeAssetID: model.feeAssetId)
            
            return .send(sender)
            
        case .data(let model):
            
            let sender = DataTransactionSender.init(fee: model.fee,
                                                    data: model.valueSender,
                                                    chainId: model.chainId,
                                                    timestamp: Date.init(milliseconds: model.timestamp))
            
            return .data(sender)
            
        default:
            return nil
        }
    }
}

fileprivate extension DomainLayer.DTO.MobileKeeper.PrepareRequest {
    
    
    func completedRequest(response: DomainLayer.DTO.MobileKeeper.Response,
                          signedWallet: DomainLayer.DTO.SignedWallet) -> DomainLayer.DTO.MobileKeeper.CompletedRequest {
    
        let completedRequest = DomainLayer.DTO.MobileKeeper.CompletedRequest(request: request,
                                                                             timestamp: timestamp,
                                                                             proof: proof,
                                                                             txId: txId,
                                                                             publicKey: signedWallet.publicKey.getPublicKeyStr(),
                                                                             response: response)
        
        return completedRequest
    }
    
    
}


fileprivate extension DomainLayer.DTO.MobileKeeper.Request  {
    
    func transactionSignature(signedWallet: DomainLayer.DTO.SignedWallet,
                              timestamp: Date) -> TransactionSignatureProtocol? {
        
        let senderPublicKey = signedWallet.publicKey.getPublicKeyStr()
        
        switch self.transaction {
        case .data(let tx):
            
            let signature = TransactionSignatureV1.data(.init(fee: tx.fee,
                                                              data: tx.data.map { $0.valueSignatureV1() },
                                                              chainId: tx.chainId ?? "",
                                                              senderPublicKey: senderPublicKey,
                                                              timestamp: timestamp.millisecondsSince1970))
            
            return signature
            
        case .invokeScript(let tx):
            
            let signature = TransactionSignatureV1.invokeScript(.init(senderPublicKey: senderPublicKey,
                                                                      fee: tx.fee,
                                                                      chainId: tx.chainId ?? "",
                                                                      timestamp: timestamp.millisecondsSince1970,
                                                                      feeAssetId: tx.feeAssetId,
                                                                      dApp: tx.dApp,
                                                                      call: tx.call?.callSigantureV1(),
                                                                      payment: tx.payment.map { $0.paymentSigantureV1() }))
            
            return signature
        case .send(let tx):
            
            let signature = TransactionSignatureV2.transfer(.init(senderPublicKey: senderPublicKey,
                                                                  recipient: tx.recipient,
                                                                  assetId: tx.assetId,
                                                                  amount: tx.amount,
                                                                  fee: tx.fee,
                                                                  attachment: tx.attachment,
                                                                  feeAssetID: tx.feeAssetID,
                                                                  chainId: tx.chainId ?? "",
                                                                  timestamp: timestamp.millisecondsSince1970))
            return signature
            
        default:
            return nil
        }
    }
}

fileprivate extension DataTransactionSender.Value  {
    
    func valueSignatureV1() -> TransactionSignatureV1.Structure.Data.Value {
        
        switch self.value {
        case .binary(let value):
            return .init(key: self.key, value: .binary(value))
            
        case .boolean(let value):
            return .init(key: self.key, value: .boolean(value))
            
        case .integer(let value):
            return .init(key: self.key, value: .integer(value))
            
        case .string(let value):
            return .init(key: self.key, value: .string(value))
        }
    }
}

fileprivate extension InvokeScriptTransactionSender.Arg.Value  {

    func argValueSigantureV1() -> TransactionSignatureV1.Structure.InvokeScript.Arg.Value {

        switch self {
        case .binary(let value):
            return .binary(value)

        case .bool(let value):
            return .bool(value)

        case .integer(let value):
            return .integer(value)

        case .string(let value):
            return .string(value)
        }
    }
}

fileprivate extension InvokeScriptTransactionSender.Payment {

    func paymentSigantureV1() -> TransactionSignatureV1.Structure.InvokeScript.Payment {
        return .init(amount: amount, assetId: assetId)
    }
}

fileprivate extension InvokeScriptTransactionSender.Arg {

    func argSigantureV1() -> TransactionSignatureV1.Structure.InvokeScript.Arg {

        return TransactionSignatureV1.Structure.InvokeScript.Arg(value: value.argValueSigantureV1())
    }
}

fileprivate extension InvokeScriptTransactionSender.Call  {

    func callSigantureV1() -> TransactionSignatureV1.Structure.InvokeScript.Call {

        return .init(function: function,
                     args: args.map { $0.argSigantureV1() })
    }

}
