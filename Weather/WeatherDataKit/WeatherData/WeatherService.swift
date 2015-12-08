//
//  WeatherService.swift
//  Weather
//
//  Created by Joyce Echessa on 10/16/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

import Foundation
import CoreLocation

final class WeatherService {
    
    typealias WeatherDataCompletionBlock = (data: WeatherData?, error: NSError?) -> ()
    
    let session = NSURLSession.sharedSession()
    
    static let sharedInstance = WeatherService()

    private init() {}
    
    func fetchWeatherDataWithLocation(location: CLLocationCoordinate2D, completion: WeatherDataCompletionBlock) {

        let urlString = "https://api.forecast.io/forecast/0331f5d94acdc4bf4ae077c9ad2e84d9/\(location.latitude),\(location.longitude)"
        let baseUrl = NSURL(string: urlString)!
        let request = NSURLRequest(URL: baseUrl)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard error == nil, let data = data else {
                completion(data: nil, error: error)
                return
            }

            do {
                guard let weatherDictionary = try NSJSONSerialization
                    .JSONObjectWithData(data, options: []) as? NSDictionary else {
                    completion(data: nil, error: nil)
                    return
                }
                let data = WeatherData(weatherDictionary: weatherDictionary)
                completion(data: data, error: nil)
            } catch {
                completion(data: nil, error: error as NSError)
            }
        }

        task.resume()
    }
}
