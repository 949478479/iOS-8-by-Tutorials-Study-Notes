//
//  CityTableViewCell.swift
//  WorldWeather
//
//  Created by 从今以后 on 15/10/16.
//  Copyright © 2015年 RayWenderlich. All rights reserved.
//

import UIKit

class CityTableViewCell: UITableViewCell {

    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var cityImageView: UIImageView!

    var cityWeather: CityWeather!

    func configureWithCityWeather(cityWeather: CityWeather) {
        self.cityWeather = cityWeather
        cityNameLabel.text = cityWeather.name
        cityImageView.image = cityWeather.cityImage
    }
}
