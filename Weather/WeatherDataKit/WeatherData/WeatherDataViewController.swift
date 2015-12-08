//
//  WeatherDataViewController.swift
//  Weather
//
//  Created by Joyce Echessa on 10/16/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

import UIKit
import CoreLocation

public class WeatherDataViewController: UIViewController {
    
    @IBOutlet public var timeLabel: UILabel!
    @IBOutlet public var summaryLabel: UILabel!
    @IBOutlet public var humidityLabel: UILabel!
    @IBOutlet public var locationLabel: UILabel!
    @IBOutlet public var temperatureLabel: UILabel!
    @IBOutlet public var precipitationLabel: UILabel!

    public func updateWeatherDataWithLocation(location: CLLocationCoordinate2D, completion: (NSError? -> Void)?) {
        WeatherService.sharedInstance.fetchWeatherDataWithLocation(location, completion: { data, error in
            dispatch_async(dispatch_get_main_queue()) {
                self.updateData(data)
                completion?(error)
            }
        })
    }

    private func updateData(data: WeatherData?) {
        guard let data = data else { return }
        timeLabel.text = data.currentTime
        summaryLabel.text = data.summary
        humidityLabel.text = String(data.humidity)
        temperatureLabel.text = String(data.temperature)
        precipitationLabel.text = String(data.precipProbability) 
    }
}

