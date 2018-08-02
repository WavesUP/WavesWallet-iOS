//
//  HistoryTypes+DisplayState.swift
//  WavesWallet-iOS
//
//  Created by Mac on 02/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension HistoryTypes.State.DisplayState {
    static func initialState(display: HistoryTypes.Display) -> HistoryTypes.State.DisplayState {
        var section: HistoryTypes.ViewModel.Section!

        section = HistoryTypes.ViewModel.Section(kind: .all, items: [.assetSkeleton,.assetSkeleton,.assetSkeleton,.assetSkeleton,.assetSkeleton,.assetSkeleton,.assetSkeleton])
        
        return .init(sections: [section])
    }
}
