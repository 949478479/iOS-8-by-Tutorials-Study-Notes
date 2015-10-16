/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var weatherIconImageView: UIImageView!

    var cityWeather: CityWeather! {
        didSet {
            if isViewLoaded() {
                configureView()
                provideDataToChildViewControllers()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if cityWeather != nil {
            configureView()
            provideDataToChildViewControllers()
        }

        configureTraitOverrideForSize(view.bounds.size)
        navigationItem.leftItemsSupplementBackButton = true
    }

    override func viewWillTransitionToSize(size: CGSize,
        withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        configureTraitOverrideForSize(size)
    }

    // MARK: - Utility methods

    private func configureView() {
        title = cityWeather.name
        weatherIconImageView.image = cityWeather.weather[0].status.weatherType.image
    }

    private func provideDataToChildViewControllers() {
        childViewControllers.forEach {
            if let cityWeatherContainer = $0 as? CityWeatherContainer {
                cityWeatherContainer.cityWeather = cityWeather
            }
        }
    }

    /*  修改子控制器的 UITraitCollection. 这里指定高度不足 1000 时, 也就是除了 iPad 竖屏之外的情况下,都属于
        compact height 的情况.当高度超过 1000 时, traitOverride 为 nil, 即恢复默认行为.*/
    private func configureTraitOverrideForSize(size: CGSize) {
        let traitOverride: UITraitCollection? = size.height < 1000 ?
            UITraitCollection(verticalSizeClass: .Compact) : nil
        childViewControllers.forEach {
            setOverrideTraitCollection(traitOverride, forChildViewController: $0)
        }
    }
}
