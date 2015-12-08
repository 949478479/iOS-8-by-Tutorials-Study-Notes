//
//  ViewController.swift
//  Weather
//
//  Created by Joyce Echessa on 10/16/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

import UIKit
import CoreLocation
import WeatherDataKit

class ViewController: WeatherDataViewController {

    let location = CLLocationCoordinate2D(latitude: 37.331793, longitude: -122.029584)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeLabel.text = "--"
        summaryLabel.text = "--"
        humidityLabel.text = "--"
        temperatureLabel.text = "--"
        precipitationLabel.text = "--"

        updateWeatherDataWithLocation(location, completion: nil)
    }
}

