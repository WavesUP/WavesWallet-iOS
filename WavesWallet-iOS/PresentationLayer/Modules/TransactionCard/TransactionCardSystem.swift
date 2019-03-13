//
//  TransactionCardSystem.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 04/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxFeedback
import RxSwift
import RxSwiftExt

private typealias Types = TransactionCard
final class TransactionCardSystem: System<TransactionCard.State, TransactionCard.Event> {

    private let transaction: DomainLayer.DTO.SmartTransaction

    //TODO: add transaction: DomainLayer.DTO.SmartTransaction
    init(transaction: DomainLayer.DTO.SmartTransaction) {
        self.transaction = transaction
    }

    override func initialState() -> State! {

//        .assetDetail,
        let sections = transaction.sections

        return State(ui: .init(sections: sections),
                     core: nil)
    }

    override func internalFeedbacks() -> [Feedback] {
        return []
    }

    override func reduce(event: Event, state: inout State) {

        switch event {
        case .viewDidAppear:
            break

        default:
            break
        }
    }
    
}

fileprivate extension DomainLayer.DTO.SmartTransaction {

    var sections: [Types.Section] {

        switch self.kind {
        case .sent(let transfer):
            return sentSection(transfer: transfer)

        case .receive(let transfer):
            return receiveSection(transfer: transfer)

        case .spamReceive(let transfer):
            return spamReceiveSection(transfer: transfer)

        case .selfTransfer(let transfer):
            return selfTransferSection(transfer: transfer)

        case .massSent(let transfer):
            return massSentSection(transfer: transfer)

        case .massReceived(let massReceive):
            break

        case .spamMassReceived(let massReceive):
            break

        case .startedLeasing(let leasing):
            break

        case .canceledLeasing(let leasing):
            break

        case .incomingLeasing(let leasing):
            break

        case .exchange(let exchange):
            break

        case .tokenGeneration(let issue):
            break

        case .tokenBurn(let issue):
            break

        case .tokenReissue(let issue):
            break

        case .createdAlias(let alias):
            break

        case .unrecognisedTransaction:
            break

        case .data(let data):
            break

        case .script(let isHasScript):
            break

        case .assetScript(let asset):
            break

        case .sponsorship(let isEnabled, let asset):
            break

        default:
            return []
        }

        return []
    }

    // MARK: Sent Sections

    func sentSection(transfer: DomainLayer.DTO.SmartTransaction.Transfer) ->  [Types.Section] {

        return transferSection(transfer: transfer,
                               generalTitle: "Sent",
                               addressTitle: "Sent to",
                               needSendAgain: true)
    }

    // MARK: Receive Sections
    func receiveSection(transfer: DomainLayer.DTO.SmartTransaction.Transfer) ->  [Types.Section] {

        return transferSection(transfer: transfer,
                               generalTitle: "Received",
                               addressTitle: "Received from")
    }

    // MARK: SpamReceive Sections
    func spamReceiveSection(transfer: DomainLayer.DTO.SmartTransaction.Transfer) ->  [Types.Section] {

        return transferSection(transfer: transfer,
                               generalTitle: "Spam Received",
                               addressTitle: "Received from")
    }

    // MARK: SelfTransfer Sections
    func selfTransferSection(transfer: DomainLayer.DTO.SmartTransaction.Transfer) ->  [Types.Section] {

        return transferSection(transfer: transfer,
                               generalTitle: "Self-transfer",
                               addressTitle: "Received from")
    }

    // MARK: MassSent Sections
    func massSentSection(transfer: DomainLayer.DTO.SmartTransaction.MassTransfer) ->  [Types.Section] {

        var rows: [Types.Row] = .init()

        let isSpam = transfer.asset.isSpam

        let rowGeneralModel = TransactionCardGeneralCell.Model(image: kind.image,
                                                               title: "Mass sent",
                                                               info: .balance(.init(balance: transfer.total,
                                                                                    sign: .minus,
                                                                                    style: .large)))

        rows.append(contentsOf:[.general(rowGeneralModel)])

        for tx in transfer.transfers {
            let name = tx.recipient.contact?.name
            let address = tx.recipient.address
            let isEditName = name != nil

            let rowRecipientModel = TransactionCardMassSentRecipientCell.Model

        }


//        let rowAddressModel = TransactionCardAddressCell.Model.init(contactDetail: .init(title: addressTitle,
//                                                                                         address: address,
//                                                                                         name: name),
//                                                                    isSpam: isSpam,
//                                                                    isEditName: isEditName)




        if let attachment = transfer.attachment {
            let rowDescriptionModel = TransactionCardDescriptionCell.Model.init(description: attachment)
            rows.append(.description(rowDescriptionModel))
        }

        var buttonsActions: [TransactionCardActionsCell.Model.Button] = .init()

//        if needSendAgain {
//            buttonsActions.append(.sendAgain)
//        }

        buttonsActions.append(contentsOf: [.viewOnExplorer, .copyTxID, .copyAllData])

        let rowActionsModel = TransactionCardActionsCell.Model(buttons: [.viewOnExplorer, .copyTxID, .copyAllData])



        rows.append(contentsOf:[.keyValue(self.rowBlockModel),
                                .keyValue(self.rowConfirmationsModel),
                                .keyBalance(self.rowFeeModel),
                                .keyValue(self.rowTimestampModel),
                                .status(self.rowStatusModel),
                                .dashedLine(.topPadding),
                                .actions(rowActionsModel)])


        let section = Types.Section(rows: rows)

        return [section]
    }


    // MARK: Transfer Sections
    func transferSection(transfer: DomainLayer.DTO.SmartTransaction.Transfer,
                         generalTitle: String,
                         addressTitle: String,
                         needSendAgain: Bool = false) ->  [Types.Section] {

        var rows: [Types.Row] = .init()

        let isSpam = transfer.asset.isSpam

        let rowGeneralModel = TransactionCardGeneralCell.Model(image: kind.image,
                                                               title: generalTitle,
                                                               info: .balance(.init(balance: transfer.balance,
                                                                                    sign: .minus,
                                                                                    style: .large)))

        let name = transfer.recipient.contact?.name
        let address = transfer.recipient.address
        let isEditName = name != nil

        let rowAddressModel = TransactionCardAddressCell.Model.init(contactDetail: .init(title: addressTitle,
                                                                                         address: address,
                                                                                         name: name),
                                                                    isSpam: isSpam,
                                                                    isEditName: isEditName)

        rows.append(contentsOf:[.general(rowGeneralModel),
                                .address(rowAddressModel)])


        if let attachment = transfer.attachment {
            let rowDescriptionModel = TransactionCardDescriptionCell.Model.init(description: attachment)
            rows.append(.description(rowDescriptionModel))
        }

        var buttonsActions: [TransactionCardActionsCell.Model.Button] = .init()

        if needSendAgain {
            buttonsActions.append(.sendAgain)
        }

        buttonsActions.append(contentsOf: [.viewOnExplorer, .copyTxID, .copyAllData])

        let rowActionsModel = TransactionCardActionsCell.Model(buttons: [.viewOnExplorer, .copyTxID, .copyAllData])



        rows.append(contentsOf:[.keyValue(self.rowBlockModel),
                                .keyValue(self.rowConfirmationsModel),
                                .keyBalance(self.rowFeeModel),
                                .keyValue(self.rowTimestampModel),
                                .status(self.rowStatusModel),
                                .dashedLine(.topPadding),
                                .actions(rowActionsModel)])


        let section = Types.Section(rows: rows)

        return [section]
    }

    var rowBlockModel: TransactionCardKeyValueCell.Model {
        let height = self.height ?? 0
        return TransactionCardKeyValueCell.Model(key: "Block", value: "\(height)")
    }

    var rowConfirmationsModel: TransactionCardKeyValueCell.Model {

        return TransactionCardKeyValueCell.Model(key: "Confirmations", value: "\(String(describing: confirmationHeight))")
    }

    var rowFeeModel: TransactionCardKeyBalanceCell.Model {
        return TransactionCardKeyBalanceCell.Model(key: "Fee", value: BalanceLabel.Model(balance: self.totalFee,
                                                                                         sign: nil,
                                                                                         style: .small))
    }

    var rowTimestampModel: TransactionCardKeyValueCell.Model {

        let formatter = DateFormatter.sharedFormatter
        formatter.dateFormat = "dd.MM.yyyy at HH:mm"
        let timestampValue = formatter.string(from: timestamp)

        return TransactionCardKeyValueCell.Model(key: "Timestamp", value: timestampValue)
    }

    var rowStatusModel: TransactionCardStatusCell.Model {
        switch status {
        case .activeNow:
            return .activeNow

        case .completed:
            return .completed

        case .unconfirmed:
            return .unconfirmed
        }
    }
}


//        Started Leasing
//        let section = Types.Section(rows: [.general,
//                                           .address,
//                                           .keyValue,
//                                           .keyValue,
//                                           .keyValue,
//                                           .keyBalance,
//                                           .dashedLine(.top),
//                                           .actions
//                                           ])

// Exchange
//        let section = Types.Section(rows: [.general,
//                                           .exchange,
//                                           .keyValue,
//                                           .keyValue,
//                                           .status,
//                                           .keyBalance,
//                                           .dashedLine(.top),
//                                           .actions
//            ])

// Self-transfer
//        let section = Types.Section(rows: [.general,
//                                           .dashedLine(.bottomPadding),
//                                           .description,
//                                           .keyValue,
//                                           .keyValue,
//                                           .keyBalance,
//                                           .status,
//                                           .dashedLine(.topPadding),
//                                           .actions
//            ])

// Canceled Leasing
//                let section = Types.Section(rows: [.general,
//                                                   .address,
//                                                   .keyValue,
//                                                   .keyValue,
//                                                   .keyBalance,
//                                                   .status,
//                                                   .dashedLine(.topPadding),
//                                                   .actions
//                    ])


// Incoming Leasing
//        let section = Types.Section(rows: [.general,
//                                           .dashedLine(.bottomPadding),
//                                           .description,
//                                           .keyValue,
//                                           .keyValue,
//                                           .keyBalance,
//                                           .status,
//                                           .dashedLine(.topPadding),
//                                           .actions
//            ])

// Mass Sent
//        let section = Types.Section(rows: [.general,
//                                           .dashedLine(.bottomPadding),
//                                           .massSentRecipient,
//                                           .massSentRecipient,
//                                           .showAll,
//                                           .keyValue,
//                                           .keyValue,
//                                           .keyBalance,
//                                           .status,
//                                           .dashedLine(.topPadding),
//                                           .actions
//            ])


