//
//  AssetsSearchViewBuilder.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 05.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import DomainLayer

struct AssetsSearchViewBuilder: ModuleBuilderOutput {
    
    typealias Input = Void
    
    var output: (([DomainLayer.DTO.Asset]) -> Void)
    
    func build(input: Input) -> UIViewController {
        let vc = StoryboardScene.AssetsSearch.assetsSearchViewController.instantiate()
        vc.system = AssetsSearchSystem()
        return vc
    }
}


