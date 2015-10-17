//
//  NoPaletteSelectedViewController.swift
//  KhromaPal
//
//  Created by 从今以后 on 15/10/17.
//  Copyright © 2015年 RayWenderlich. All rights reserved.
//

import UIKit

class NoPaletteSelectedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
    }
}
