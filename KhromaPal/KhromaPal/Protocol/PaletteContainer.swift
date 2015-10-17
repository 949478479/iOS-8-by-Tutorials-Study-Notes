//
//  PaletteContainer.swift
//  KhromaPal
//
//  Created by 从今以后 on 15/10/17.
//  Copyright © 2015年 RayWenderlich. All rights reserved.
//

import Foundation

protocol PaletteDisplayContainer {
    func currentlyDisplayedPallette() -> ColorPalette?
}

protocol PaletteSelectionContainer {
    func currentlySelectedPalette() -> ColorPalette?
}
