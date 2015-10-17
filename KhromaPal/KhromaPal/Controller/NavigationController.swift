//
//  NavigationController.swift
//  KhromaPal
//
//  Created by 从今以后 on 15/10/17.
//  Copyright © 2015年 RayWenderlich. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController, PaletteDisplayContainer, PaletteSelectionContainer {

    func currentlyDisplayedPallette() -> ColorPalette? {
        return (topViewController as? PaletteDisplayContainer)?.currentlyDisplayedPallette() ?? nil
    }

    func currentlySelectedPalette() -> ColorPalette? {
        return (topViewController as? PaletteSelectionContainer)?.currentlySelectedPalette() ?? nil
    }
}
