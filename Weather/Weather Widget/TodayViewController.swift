//
//  TodayViewController.swift
//  Weather Widget
//
//  Created by 从今以后 on 15/12/7.
//  Copyright © 2015年 Appcoda. All rights reserved.
//

import UIKit
import CoreLocation
import WeatherDataKit
import NotificationCenter

class TodayViewController: WeatherDataViewController {

    private var _opening = false
    @IBOutlet private var _detailButton: UIButton!
    @IBOutlet private var _detailContainerView: UIView!
    @IBOutlet private var _detailContainerViewHeightConstraint: NSLayoutConstraint!
    private let _location = CLLocationCoordinate2D(latitude: 37.331793, longitude: -122.029584)

    override func viewDidLoad() {
        super.viewDidLoad()
        _loadState()
        _showDetail(_opening, animated: false)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        _saveState()
    }

    @IBAction func _detailButtonDidTapped(sender: UIButton) {
        _opening = !_opening
        _showDetail(_opening, animated: true)
    }
}

extension TodayViewController: NCWidgetProviding {

    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        updateWeatherDataWithLocation(_location) { error in
            if error == nil {
                self._saveState()
                completionHandler(.NewData)
            } else {
                completionHandler(.NoData)
            }
        }
    }

    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets()
    }
}

// MARK: Private
private extension TodayViewController {

    func _saveState() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(_opening, forKey: "opening")
        userDefaults.setObject(timeLabel.text, forKey: "timeLabel")
        userDefaults.setObject(summaryLabel.text, forKey: "summaryLabel")
        userDefaults.setObject(humidityLabel.text, forKey: "humidityLabel")
        userDefaults.setObject(temperatureLabel.text, forKey: "temperatureLabel")
        userDefaults.setObject(precipitationLabel.text, forKey: "precipitationLabel")
    }

    func _loadState() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        _opening = userDefaults.boolForKey("opening")
        timeLabel.text = userDefaults.stringForKey("timeLabel") ?? "--"
        summaryLabel.text = userDefaults.stringForKey("summaryLabel") ?? "--"
        humidityLabel.text = userDefaults.stringForKey("humidityLabel") ?? "--"
        temperatureLabel.text = userDefaults.stringForKey("temperatureLabel") ?? "--"
        precipitationLabel.text = userDefaults.stringForKey("precipitationLabel") ?? "--"
    }

    func _showDetail(showDetail: Bool, animated: Bool) {

        _detailButton.enabled = true
        if showDetail { _detailContainerView.hidden = false }

        let animations = {
            self._detailButton.transform = showDetail ? CGAffineTransformIdentity :
                CGAffineTransformMakeRotation(CGFloat(M_PI))
            self._detailContainerViewHeightConstraint.constant = showDetail ? 128 : 0
        }

        let completion = { (finished: Bool) in
            self._detailButton.enabled = true
            if !showDetail { self._detailContainerView.hidden = true }
        }

        if animated {
            UIView.animateWithDuration(0.4, animations: animations, completion: completion)
        } else {
            animations()
            completion(true)
        }
    }
}
