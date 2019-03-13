//
//  TransactionCardMassSentRecipientCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 07/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class TransactionCardMassSentRecipientCell: UITableViewCell, Reusable {

    struct Model {
        let title: String
        let contactDetail: ContactDetailView.Model
        let balance: BalanceLabel.Model?
        let isEditName: Bool
    }

    @IBOutlet private var contactDetailView: ContactDetailView!

    @IBOutlet private var balanceLabel: BalanceLabel!

    @IBOutlet private var copyButton: UIButton!

    @IBOutlet private var addressBookButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    //TODO: Copy button
    @IBAction func actionCopyButton(_ sender: Any) {

    }

    @IBAction func actionAddressBookButton(_ sender: Any) {

    }
}

// TODO: ViewConfiguration

extension TransactionCardMassSentRecipientCell: ViewConfiguration {

    func update(with model: Model) {

//        balanceLabel.update/
    }
}
