//
//  WeatherData.swift
//  Weather
//
//  Created by Joyce Echessa on 10/16/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

import Foundation

final class WeatherData {
    
    let summary: String
    let humidity: Double
    let temperature: Int
    let currentTime: String
    let precipProbability: Double

    static let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter
    }()

    init(weatherDictionary: NSDictionary) {
        let weather = weatherDictionary["currently"] as? NSDictionary

        summary = weather?["summary"] as? String ?? ""
        humidity = weather?["humidity"] as? Double ?? 0
        temperature = weather?["temperature"] as? Int ?? 0
        precipProbability = weather?["precipProbability"] as? Double ?? 0

        if let timeInterval = weather?["time"] as? NSTimeInterval {
            let date = NSDate(timeIntervalSince1970: timeInterval)
            currentTime = WeatherData.dateFormatter.stringFromDate(date)
        } else {
            currentTime = ""
        }
    }
}
